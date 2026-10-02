#!/usr/bin/env python3
"""Genera el backend estático de ERP Flutter (carpeta backend/api).

Todos los datos son ficticios. Las fechas no se guardan como fechas absolutas
sino como desplazamientos en días laborables respecto a "hoy"
(`workday_offset`: 0 = hoy, 1 = el día laborable anterior, ...). La app los
materializa en tiempo de ejecución, de modo que la demo siempre muestra
actividad reciente aunque el JSON se haya generado hace meses.

Uso:  python3 tool/generate_backend.py
"""

import json
import math
import random
import wave
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
API_DIR = ROOT / "backend" / "api"
SEED = 20261002
WORKDAYS_BACK = 60

# Oficina ficticia (coordenadas genéricas del centro de Valencia).
OFFICE_LAT, OFFICE_LNG = 39.4699, -0.3763

USERS = [
    {"id": 1, "name": "Laura Martín", "email": "superadmin@erpflutter.dev", "role": "superadmin"},
    {"id": 2, "name": "Carlos Ruiz", "email": "admin@erpflutter.dev", "role": "admin"},
    {"id": 3, "name": "Ana López", "email": "usuario@erpflutter.dev", "role": "user"},
    {"id": 4, "name": "Javier Torres", "email": "trabajador@erpflutter.dev", "role": "worker"},
    {"id": 5, "name": "Marta Sánchez", "email": "marta@erpflutter.dev", "role": "worker"},
    {"id": 6, "name": "Cliente Demo S.L.", "email": "cliente@erpflutter.dev", "role": "customer"},
    {"id": 7, "name": "Proveedor Demo S.A.", "email": "proveedor@erpflutter.dev", "role": "supplier"},
]
DEMO_PASSWORD = "demo1234"

# Usuarios que fichan (personal interno).
STAFF_IDS = [1, 2, 3, 4, 5]

# Usuarios que ya han fichado la entrada hoy (para que la demo muestre ambos
# estados del botón de fichaje según con quién se entre).
WORKING_TODAY = {2, 4, 5}

REMARKS = [
    None, None, None, None, None, None, None,
    "Fichaje desde la app",
    "Visita a cliente por la mañana",
    "Teletrabajo",
]

INCIDENT_REASONS = [
    "Olvidé fichar la entrada al llegar a la oficina.",
    "La app no tenía cobertura y fiché más tarde.",
    "Salí antes por cita médica, adjunto justificante.",
    "Fiché la salida en lugar de la entrada por error.",
    "Estuve en una visita a cliente y fiché al volver.",
    "Se me pasó fichar la vuelta de la pausa de comida.",
    "El móvil se quedó sin batería antes de fichar.",
    "Fichaje duplicado, el primero es incorrecto.",
]


def hhmm(hour: int, minute: int) -> str:
    return f"{hour:02d}:{minute:02d}"


def jitter(base_h: int, base_m: int, spread: int, rnd: random.Random) -> str:
    total = base_h * 60 + base_m + rnd.randint(-spread, spread)
    return hhmm(total // 60, total % 60)


def location(rnd: random.Random):
    if rnd.random() < 0.2:
        return None, None
    return (
        round(OFFICE_LAT + rnd.uniform(-0.01, 0.01), 6),
        round(OFFICE_LNG + rnd.uniform(-0.01, 0.01), 6),
    )


def build_records(rnd: random.Random):
    records = []
    next_id = 1

    def add(user_id, offset, time, rtype):
        nonlocal next_id
        lat, lng = location(rnd)
        records.append({
            "id": next_id,
            "user_id": user_id,
            "workday_offset": offset,
            "time": time,
            "type": rtype,
            "remarks": rnd.choice(REMARKS),
            "latitude": lat,
            "longitude": lng,
        })
        next_id += 1

    for offset in range(WORKDAYS_BACK, 0, -1):
        for user_id in STAFF_IDS:
            # Algún día suelto sin fichajes (vacaciones, ausencias...).
            if rnd.random() < 0.06:
                continue
            add(user_id, offset, jitter(8, 0, 15, rnd), 0)
            add(user_id, offset, jitter(14, 0, 10, rnd), 1)
            add(user_id, offset, jitter(15, 0, 10, rnd), 0)
            add(user_id, offset, jitter(17, 30, 20, rnd), 1)

    for user_id in sorted(WORKING_TODAY):
        add(user_id, 0, jitter(8, 0, 10, rnd), 0)

    return records


def build_incidents(rnd: random.Random, records):
    by_user = {}
    for record in records:
        if record["workday_offset"] > 0:
            by_user.setdefault(record["user_id"], []).append(record)

    incidents = []
    next_id = 1
    for user_id in STAFF_IDS:
        candidates = by_user[user_id]
        for record in rnd.sample(candidates, 4):
            offset = record["workday_offset"]
            created_offset = max(offset - rnd.randint(0, 2), 0)
            # Las más recientes siguen pendientes; las antiguas ya están resueltas.
            if created_offset <= 5:
                status = 0
            else:
                status = rnd.choice([1, 1, 2])
            wants_date = rnd.random() < 0.7
            h, m = map(int, record["time"].split(":"))
            requested_time = jitter(h, m, 30, rnd) if wants_date else None
            incidents.append({
                "id": next_id,
                "clock_in_record_id": record["id"],
                "reporter_user_id": user_id,
                "target_user_id": user_id,
                "status": status,
                "reason": rnd.choice(INCIDENT_REASONS),
                "requested_workday_offset": offset if wants_date else None,
                "requested_time": requested_time,
                "requested_type": record["type"] if wants_date else None,
                "created_workday_offset": created_offset,
                "created_time": jitter(18, 30, 60, rnd),
            })
            next_id += 1
    return incidents


# Festivos fijos (MM-DD), se aplican a cualquier año.
NATIONAL_HOLIDAYS = [
    "01-01", "01-06", "03-19", "05-01", "08-15", "10-09",
    "10-12", "11-01", "12-06", "12-08", "12-25",
]
COMPANY_HOLIDAYS = ["12-24", "12-31"]
ANNUAL_ALLOWANCE = 23

HOLIDAY_REASONS = [
    "Viaje familiar", "Asuntos personales", "Puente", None, None,
    "Boda de un familiar", "Vacaciones de verano",
]


def build_holidays(rnd: random.Random):
    """Períodos de vacaciones con fechas relativas a hoy (en días naturales).

    `start_offset` / `end_offset`: días respecto a hoy (negativo = pasado).
    """
    periods = []
    next_id = 1

    def add(worker_id, start, length, status, created_by, reason=None):
        nonlocal next_id
        periods.append({
            "id": next_id,
            "worker_id": worker_id,
            "start_offset": start,
            "end_offset": start + length - 1,
            "status": status,
            "created_by": created_by,
            "reason": reason,
        })
        next_id += 1

    for worker_id in STAFF_IDS:
        shift = rnd.randint(-6, 6)
        # Cierre de empresa (asignado por la empresa) hace unas semanas.
        add(worker_id, -60 + shift, 7, "approved", "company", "Cierre de verano")
        # Vacaciones de verano solicitadas y aprobadas.
        add(worker_id, -110 + shift * 2, 8, "approved", "worker", "Vacaciones de verano")
        # Algún día suelto ya disfrutado.
        add(worker_id, -25 + shift, rnd.randint(1, 2), "approved", "worker", rnd.choice(HOLIDAY_REASONS))
        # Una solicitud rechazada en el pasado.
        if rnd.random() < 0.6:
            add(worker_id, -40 + shift, 3, "rejected", "worker", rnd.choice(HOLIDAY_REASONS))
        # Futuras: aprobadas y pendientes de revisar.
        add(worker_id, 45 + shift * 2, 5, "approved", "worker", rnd.choice(HOLIDAY_REASONS))
        add(worker_id, 12 + rnd.randint(0, 12), rnd.randint(2, 5), "pending", "worker", rnd.choice(HOLIDAY_REASONS))
        if rnd.random() < 0.5:
            add(worker_id, 70 + rnd.randint(0, 20), rnd.randint(3, 8), "pending", "worker", rnd.choice(HOLIDAY_REASONS))
    return periods


# Conversaciones 1 a 1. Cada mensaje: (remitente, minutos atrás, texto, leído).
# "leído" indica si el destinatario ya lo había abierto al generar los datos.
CONVERSATIONS = [
    ((1, 2), [
        (1, 4320, "Carlos, ¿me pasas el resumen de horas del equipo de este mes?", True),
        (2, 4300, "Claro, te lo preparo esta tarde.", True),
        (2, 2900, "Te lo acabo de dejar en la carpeta compartida.", True),
        (1, 2880, "Perfecto, gracias.", True),
        (2, 95, "Laura, hay dos solicitudes de vacaciones pendientes de revisar.", False),
    ]),
    ((2, 3), [
        (3, 1500, "Hola Carlos, ayer olvidé fichar la salida. Ya he abierto una incidencia.", True),
        (2, 1480, "Vale Ana, la reviso hoy.", True),
        (2, 40, "Revisada y aprobada. Recuerda fichar al salir 😉", False),
    ]),
    ((1, 3), [
        (1, 10100, "Bienvenida al equipo, Ana. Cualquier duda me dices.", True),
        (3, 10080, "¡Muchas gracias, Laura!", True),
    ]),
    ((2, 6), [
        (6, 2200, "Buenos días, ¿podríais confirmar la visita técnica del jueves?", True),
        (2, 2150, "Buenos días. Confirmada para el jueves a las 10:00.", True),
        (6, 300, "Perfecto. ¿Nos enviaréis el presupuesto actualizado?", False),
        (6, 290, "Lo necesitamos para cerrar el pedido esta semana.", False),
    ]),
    ((3, 6), [
        (3, 5000, "Le adjunto la documentación que nos pidió por correo.", True),
        (6, 4900, "Recibida, gracias.", True),
    ]),
    ((2, 7), [
        (7, 1800, "Os confirmamos que el material sale mañana del almacén.", True),
        (2, 1790, "Genial, ¿con qué agencia de transporte?", True),
        (7, 120, "Con la de siempre. Llegará en 48-72 h.", False),
    ]),
    ((2, 4), [
        (2, 3000, "Javier, mañana necesito que pases por la obra de la calle Colón.", True),
        (4, 2950, "Sin problema, voy a primera hora.", True),
        (4, 60, "Ya estoy aquí. Falta material para terminar hoy.", True),
        (2, 50, "Vale, te lo mando con Marta esta tarde.", False),
    ]),
    ((4, 5), [
        (5, 700, "¿Te recojo mañana para ir al cliente?", True),
        (4, 680, "Sí, a las 7:45 en la oficina.", True),
        (5, 30, "Perfecto, allí estaré.", False),
    ]),
    ((1, 7), [
        (1, 8000, "Necesitamos revisar las condiciones del contrato de suministro.", True),
        (7, 7900, "Sin problema, ¿os va bien una reunión la semana que viene?", False),
    ]),
]

AUTO_REPLIES = [
    "Recibido, gracias.",
    "Perfecto, lo reviso y te digo algo.",
    "De acuerdo 👍",
    "Ahora mismo estoy reunido, te respondo en un rato.",
    "Gracias por avisar.",
    "¡Genial!",
]


def build_messages():
    conversations = []
    messages = []
    next_id = 1
    for conv_id, (participants, items) in enumerate(CONVERSATIONS, start=1):
        conversations.append({"id": conv_id, "participants": list(participants)})
        for sender, minutes_ago, body, read in items:
            messages.append({
                "id": next_id,
                "conversation_id": conv_id,
                "sender_id": sender,
                "minutes_ago": minutes_ago,
                "body": body,
                "read": read,
            })
            next_id += 1
    return {
        "conversations": conversations,
        "messages": messages,
        "auto_replies": AUTO_REPLIES,
    }


# ── Clientes ───────────────────────────────────────────────────────────────
# Empresas inventadas. Los CIF usan el prefijo "X" para que no puedan
# coincidir con ninguno real.

CLIENT_NAMES = [
    "Cliente Demo S.L.", "Talleres Albufera S.L.", "Construcciones Turia S.A.",
    "Hostelería Malvarrosa S.L.", "Clínica Dental Ruzafa", "Frutas Huerta Norte S.L.",
    "Instalaciones Levante Sur", "Panadería El Carmen", "Gestoría Benimaclet",
    "Hotel Mar Azul", "Logística Puerto Valencia S.L.", "Farmacia Plaza Redonda",
    "Colegio Sant Vicent", "Inmobiliaria Cabanyal", "Restaurante La Barraca",
    "Óptica Visión Clara", "Autoescuela Patraix", "Muebles Alfafar S.L.",
    "Cerámicas Manises S.A.", "Bodegas Requena Alta", "Gimnasio Campanar Fit",
    "Academia Idiomas Russafa", "Papelería Xàtiva", "Floristería Jardí",
    "Imprenta Gráficas Silla", "Veterinaria Paterna", "Peluquería Estilo 10",
    "Electrodomésticos Torrent",
]

CITIES = [
    ("Valencia", "46001"), ("Valencia", "46004"), ("Valencia", "46021"),
    ("Paterna", "46980"), ("Torrent", "46900"), ("Manises", "46940"),
    ("Alfafar", "46910"), ("Silla", "46460"), ("Xàtiva", "46800"),
    ("Requena", "46340"), ("Burjassot", "46100"), ("Mislata", "46920"),
]

STREETS = [
    "C/ Mayor", "Av. del Puerto", "C/ de la Paz", "Av. Blasco Ibáñez",
    "C/ Colón", "Pol. Ind. Fuente del Jarro, calle 4", "C/ Sueca",
    "Av. Pérez Galdós", "C/ Cuba", "Camino Real", "C/ San Vicente",
]

CONTACT_NAMES = [
    "Pedro Gil", "Lucía Navarro", "Sergio Moreno", "Elena Castillo",
    "Pablo Ortega", "Irene Vidal", "Andrés Ferrer", "Nuria Soler",
    "Raúl Peris", "Cristina Llorens", "Diego Bosch", "Sara Pons",
]

CLIENT_REMARKS = [
    None, None, None,
    "Llamar antes de ir, el acceso es por la puerta trasera.",
    "Horario de recepción de mercancía de 8:00 a 13:00.",
    "Cliente preferente: revisar presupuestos en 24 h.",
    "Pedir siempre número de pedido antes de facturar.",
    "Aparcamiento en zona azul; usar el parking del polígono.",
]

PAYMENT_CONDITIONS = ["Contado", "30 días", "60 días", "30-60 días"]
PAYMENT_METHODS = ["Transferencia", "Recibo domiciliado", "Confirming", "Tarjeta", None]
RESPONSIBLES = ["Laura Martín", "Carlos Ruiz", None]

# Catálogo ficticio de conceptos facturables: (concepto, precio unitario).
CONCEPTS = [
    ("Hora de mano de obra técnico", 32.0),
    ("Desplazamiento", 18.5),
    ("Mantenimiento preventivo mensual", 95.0),
    ("Revisión de instalación eléctrica", 120.0),
    ("Cable de red Cat6 (m)", 0.85),
    ("Router empresarial", 189.0),
    ("Licencia antivirus anual", 39.9),
    ("Sustitución de luminaria LED", 27.5),
    ("Material de fontanería", 46.2),
    ("Instalación de punto de acceso Wi-Fi", 75.0),
    ("Copia de seguridad en la nube (mes)", 15.0),
    ("Bolsa de horas de soporte (10 h)", 290.0),
]

DOCUMENT_TYPES = {
    # tipo: (prefijo, estados (etiqueta, tono), máximo por cliente, días máximos hacia atrás)
    # El tono indica el color en la app: success, pending, error, info o neutral.
    "budgets": ("PRE", [("Pendiente", "pending"), ("Aceptado", "success"),
                        ("Rechazado", "error")], 6, 365),
    "orders": ("PED", [("Pendiente", "pending"), ("En curso", "info"),
                       ("Servido", "success")], 5, 300),
    "delivery_notes": ("ALB", [("Pendiente de facturar", "pending"),
                               ("Facturado", "success")], 6, 300),
    "invoices": ("FAC", [("Pagada", "success"), ("Pendiente", "pending"),
                         ("Vencida", "error")], 8, 365),
    "recurrent_invoices": ("FR", [("Activa", "success"), ("Pausada", "neutral")], 2, 400),
}

DOCUMENT_TITLES = {
    "budgets": ["Presupuesto renovación red", "Presupuesto mantenimiento anual",
                "Presupuesto iluminación LED", "Ampliación instalación"],
    "orders": ["Pedido material oficina", "Pedido equipos de red", "Pedido urgente"],
    "delivery_notes": ["Entrega de material", "Servicio técnico", "Instalación"],
    "invoices": ["Servicios del mes", "Factura de instalación", "Material y mano de obra"],
    "recurrent_invoices": ["Cuota de mantenimiento", "Soporte informático mensual"],
}


def build_clients(rnd: random.Random):
    clients = []
    for index, name in enumerate(sorted(CLIENT_NAMES, key=lambda n: n != "Cliente Demo S.L."), start=1):
        city, postcode = rnd.choice(CITIES)
        slug = "".join(ch for ch in name.lower() if ch.isalnum())[:14]
        phone = f"96{rnd.randint(1000000, 9999999)}"
        addresses = [{
            "alias": "Sede principal",
            "address": f"{rnd.choice(STREETS)}, {rnd.randint(1, 120)}",
            "city": city,
            "postcode": postcode,
            "phone": phone,
            "email": f"info@{slug}.example",
            "billing": True,
            "delivering": rnd.random() < 0.6,
        }]
        if rnd.random() < 0.4:
            city2, postcode2 = rnd.choice(CITIES)
            addresses.append({
                "alias": rnd.choice(["Almacén", "Tienda", "Nave 2", "Delegación"]),
                "address": f"{rnd.choice(STREETS)}, {rnd.randint(1, 120)}",
                "city": city2,
                "postcode": postcode2,
                "phone": None,
                "email": None,
                "billing": False,
                "delivering": True,
            })
        contacts = [
            {
                "name": contact,
                "phone": f"6{rnd.randint(10000000, 99999999)}",
                "email": f"{contact.split()[0].lower()}@{slug}.example",
            }
            for contact in rnd.sample(CONTACT_NAMES, rnd.randint(0, 2))
        ]
        clients.append({
            "id": index,
            "code": 430000 + index,
            "name": name,
            "vat": f"X{rnd.randint(10000000, 99999999)}",
            "active": index == 1 or rnd.random() > 0.12,
            "remarks": rnd.choice(CLIENT_REMARKS),
            "discount": rnd.choice([0, 0, 0, 5, 10]),
            "responsible": rnd.choice(RESPONSIBLES),
            "payment_condition": rnd.choice(PAYMENT_CONDITIONS),
            "payment_method": rnd.choice(PAYMENT_METHODS),
            "phone": phone,
            "email": f"info@{slug}.example",
            "city": city,
            "addresses": addresses,
            "contacts": contacts,
        })
    return clients


def build_client_documents(rnd: random.Random, clients):
    """Documentos comerciales por tipo. `days_ago` se resuelve en la app."""
    result = {}
    for doc_type, (prefix, statuses, max_count, max_days) in DOCUMENT_TYPES.items():
        docs = []
        for client in clients:
            count = rnd.randint(0, max_count) if client["id"] != 1 else max_count
            for _ in range(count):
                lines = []
                for concept, price in rnd.sample(CONCEPTS, rnd.randint(1, 5)):
                    units = rnd.choice([1, 1, 2, 3, 4, 5, 8, 10, 25, 50])
                    lines.append({
                        "concept": concept,
                        "units": units,
                        "unit_price": price,
                        "total": round(units * price, 2),
                    })
                base = round(sum(line["total"] for line in lines), 2)
                tax = round(base * 0.21, 2)
                docs.append({
                    "client_id": client["id"],
                    "name": rnd.choice(DOCUMENT_TITLES[doc_type]),
                    "days_ago": rnd.randint(0, max_days),
                    "status": rnd.choice(statuses),
                    "description": rnd.choice([None, None, "Según condiciones acordadas.",
                                               "Incluye retirada del material antiguo."]),
                    "total_base": base,
                    "total_tax": tax,
                    "total": round(base + tax, 2),
                    "lines": lines,
                })
        # Numeración correlativa por antigüedad, como haría el ERP.
        docs.sort(key=lambda d: -d["days_ago"])
        for seq, doc in enumerate(docs, start=1):
            doc["status_label"], doc["status_tone"] = doc.pop("status")
            doc["id"] = seq
            doc["number"] = f"{prefix}-{seq:05d}"
        result[doc_type] = [
            {key: doc[key] for key in ("id", "client_id", "number", "name", "days_ago",
                                       "status_label", "status_tone", "description", "total_base",
                                       "total_tax", "total", "lines")}
            for doc in docs
        ]
    return result


# ── Técnicos y partes de visita ────────────────────────────────────────────

# Personal que puede asignarse a visitas y trabajos (los internos de la demo
# más técnicos de campo sin acceso a la app).
WORKERS = [
    "Laura Martín", "Carlos Ruiz", "Ana López", "Javier Torres", "Marta Sánchez",
    "Luis Herrero", "Pilar Gómez", "Toni Climent", "Rosa Beltrán",
]

# (nombre de la visita, descripción posible). A veces se deja sin descripción.
VISIT_TEMPLATES = [
    ("Reunión de seguimiento",
     "Repasamos el estado de los trabajos pendientes y acordamos fechas para la próxima fase."),
    ("Presentación de propuesta",
     "Se presenta la propuesta económica. El cliente la revisará con dirección esta semana."),
    ("Revisión de la instalación",
     "Revisión general de la instalación. Todo correcto salvo un punto de acceso con poca cobertura."),
    ("Visita comercial",
     "Primera toma de contacto. Interesados en el mantenimiento anual y en ampliar la red."),
    ("Toma de medidas",
     "Tomamos medidas de la nave para el nuevo cableado. Pendiente enviar presupuesto."),
    ("Formación al personal",
     "Formación de una hora al personal de recepción sobre el nuevo sistema."),
    ("Revisión de incidencias",
     "El cliente comenta cortes puntuales de conexión. Se deja registro para el técnico."),
    ("Firma de contrato",
     "Firmado el contrato de mantenimiento anual. Empieza el mes que viene."),
    ("Auditoría de red",
     "Inventario de equipos y revisión de la seguridad de la red. Informe en una semana."),
    ("Demostración de producto",
     "Demostración del nuevo sistema de copias en la nube. Piden una prueba de 30 días."),
]


def build_workers():
    return [{"id": i, "name": name} for i, name in enumerate(WORKERS, start=1)]


def build_visit_reports(rnd: random.Random, clients):
    """Visitas comerciales. La fecha es `workday_offset` + `time`."""
    visits = []
    for client in clients:
        count = 10 if client["id"] == 1 else rnd.randint(0, 7)
        for _ in range(count):
            offset = rnd.randint(0, 25) if rnd.random() < 0.35 else rnd.randint(0, 250)
            hour = rnd.randint(9, 17)
            visits.append({
                "client_id": client["id"],
                "name": (template := rnd.choice(VISIT_TEMPLATES))[0],
                "workday_offset": offset,
                "time": hhmm(hour, rnd.choice([0, 15, 30, 45])),
                "duration_minutes": rnd.choice([30, 45, 60, 60, 90, 120]),
                "worker_ids": sorted(rnd.sample(range(1, len(WORKERS) + 1), rnd.randint(1, 2))),
                "description": template[1] if rnd.random() < 0.85 else None,
                "travel_distance_km": rnd.choice([None, round(rnd.uniform(2, 60), 1)]),
                "travel_time_minutes": rnd.choice([None, rnd.choice([10, 15, 20, 30, 45])]),
            })
    visits.sort(key=lambda v: (-v["workday_offset"], v["time"]))
    for seq, visit in enumerate(visits, start=1):
        visit["id"] = seq
    return [{"id": v.pop("id"), **v} for v in visits]


# ── Partes de trabajo ──────────────────────────────────────────────────────

# Catálogo ficticio: (referencia, concepto, precio unitario en €).
PRODUCTS = [
    ("MO-TEC", "Mano de obra técnico (h)", 32.0),
    ("MO-OFI", "Mano de obra oficial (h)", 28.0),
    ("DESP", "Desplazamiento", 18.5),
    ("CAB-C6", "Cable de red Cat6 (m)", 0.85),
    ("RJ45", "Conector RJ45", 0.6),
    ("SW-24", "Switch 24 puertos", 189.0),
    ("AP-WIFI", "Punto de acceso Wi-Fi", 119.0),
    ("ROUT-PRO", "Router empresarial", 189.0),
    ("LED-60", "Panel LED 60x60", 34.9),
    ("MAG-16", "Magnetotérmico 16 A", 9.5),
    ("DIF-40", "Diferencial 40 A", 42.0),
    ("TUB-20", "Tubo corrugado 20 mm (m)", 0.45),
    ("SAI-1K", "SAI 1000 VA", 145.0),
    ("CAM-IP", "Cámara IP exterior", 89.0),
    ("FONT-KIT", "Kit de fontanería", 46.2),
]

# Productos que se cobran por hora: sus unidades son horas de trabajo.
HOURLY_REFS = {"MO-TEC", "MO-OFI"}

# Estados del ERP: 1-3 activos, 4-8 finalizados (el 0, pendiente, no se expone).
ACTIVE_STATUSES = [1, 1, 2, 2, 2, 3]
FINISHED_STATUSES = [4, 4, 4, 5, 6, 7, 7, 8]

# (nombre del parte, descripción, conceptos de producto habituales)
WORK_TEMPLATES = [
    ("Instalación de red", "Cableado estructurado de la planta baja y conexión al rack.",
     ["CAB-C6", "RJ45", "SW-24", "MO-TEC"]),
    ("Mantenimiento preventivo", "Revisión trimestral de equipos y limpieza del rack.",
     ["MO-TEC", "DESP"]),
    ("Avería eléctrica", "Salta el diferencial del cuadro secundario de forma intermitente.",
     ["DIF-40", "MAG-16", "MO-OFI", "DESP"]),
    ("Cambio de iluminación", "Sustitución de pantallas fluorescentes por paneles LED.",
     ["LED-60", "MO-OFI"]),
    ("Instalación Wi-Fi", "Ampliación de cobertura en la zona de almacén.",
     ["AP-WIFI", "CAB-C6", "MO-TEC"]),
    ("Sustitución de router", "Cambio de router por avería y reconfiguración de la VPN.",
     ["ROUT-PRO", "MO-TEC", "DESP"]),
    ("Videovigilancia", "Instalación de cámaras en accesos y configuración de grabación.",
     ["CAM-IP", "CAB-C6", "MO-TEC"]),
    ("Reparación de fontanería", "Fuga en el baño de la primera planta.",
     ["FONT-KIT", "MO-OFI", "DESP"]),
    ("Instalación de SAI", "Protección del servidor ante cortes de suministro.",
     ["SAI-1K", "MO-TEC"]),
]

WORK_REMARKS = [
    None, None, None,
    "Dejar el material sobrante en el almacén del cliente.",
    "El cliente pide que se avise 30 minutos antes de llegar.",
    "Pendiente de confirmar la segunda fase con el responsable.",
    "Acceso con tarjeta: pedirla en recepción.",
]


def build_products():
    return [{"id": i, "ref": ref, "concept": concept, "price": price, "hourly": ref in HOURLY_REFS}
            for i, (ref, concept, price) in enumerate(PRODUCTS, start=1)]


def fake_signature(rnd: random.Random):
    """Trazos de una firma inventada en coordenadas 0..1 (ancho x alto)."""
    strokes = []
    x = 0.12
    for _ in range(rnd.randint(2, 3)):
        stroke = []
        width = rnd.uniform(0.18, 0.3)
        phase = rnd.uniform(0, 6.28)
        for i in range(28):
            t = i / 27
            px = x + width * t
            py = 0.55 + 0.18 * math.sin(phase + t * rnd.uniform(9, 13)) * (1 - 0.4 * t)
            stroke.append([round(px, 3), round(py, 3)])
        strokes.append(stroke)
        x += width + rnd.uniform(0.02, 0.06)
    # Rúbrica final.
    strokes.append([[round(0.1 + 0.8 * i / 15, 3), round(0.78 + 0.03 * math.sin(i), 3)]
                    for i in range(16)])
    return strokes


def build_work_reports(rnd: random.Random, clients):
    products = {ref: i for i, (ref, _, _) in enumerate(PRODUCTS, start=1)}
    concepts = {ref: concept for ref, concept, _ in PRODUCTS}
    prices = {ref: price for ref, _, price in PRODUCTS}
    reports = []
    for client in clients:
        count = 8 if client["id"] == 1 else rnd.randint(1, 6)
        address = client["addresses"][0]
        for _ in range(count):
            name, description, refs = rnd.choice(WORK_TEMPLATES)
            active = rnd.random() < 0.4
            status = rnd.choice(ACTIVE_STATUSES if active else FINISHED_STATUSES)
            # Los activos son recientes o de los próximos días; los finalizados, del pasado.
            offset = rnd.randint(0, 15) if active else rnd.randint(1, 220)
            lines = []
            if status != 1:
                for ref in rnd.sample(refs, rnd.randint(1, len(refs))):
                    is_labour = ref.startswith("MO") or ref == "DESP"
                    units = rnd.choice([1, 2, 3]) if is_labour else rnd.choice([1, 2, 4, 10, 25])
                    duration = rnd.choice([30, 60, 90, 120]) if is_labour else 0
                    if ref in HOURLY_REFS:
                        # La mano de obra se cobra por horas: unidades = duración.
                        units = round(duration / 60, 2)
                    elif ref == "DESP":
                        units = 1  # Un desplazamiento por línea.
                    lines.append({
                        "product_id": products[ref],
                        "concept": concepts[ref],
                        "units": units,
                        "duration": duration,
                        "price": prices[ref],
                    })
            reports.append({
                "name": name,
                "client_id": client["id"],
                "workday_offset": offset,
                "status": status,
                "description": description if rnd.random() < 0.85 else None,
                "remarks": rnd.choice(WORK_REMARKS),
                "address": address["address"],
                "city": address["city"],
                "worker_ids": sorted(rnd.sample(range(3, 10), rnd.randint(1, 2))),
                "lines": lines,
                "signature": fake_signature(rnd) if status >= 4 and rnd.random() < 0.7 else None,
            })
    # Que los técnicos con acceso a la app (3, 4 y 5) tengan siempre partes activos.
    for worker_id in (3, 4, 5):
        for report in [r for r in reports if r["status"] <= 3][worker_id::7][:2]:
            if worker_id not in report["worker_ids"]:
                report["worker_ids"] = sorted(report["worker_ids"] + [worker_id])
    reports.sort(key=lambda r: -r["workday_offset"])
    result = []
    for seq, report in enumerate(reports, start=1):
        result.append({"id": seq, "code": f"PT-{seq:05d}", **report})
    return result


# ── Archivos de ejemplo de los partes ──────────────────────────────────────
# Las imágenes son ilustraciones que dibuja tool/render_demo_files_test.dart;
# la nota de voz es un WAV sintético generado aquí.

DEMO_FILES_DIR = ROOT / "assets" / "demo_files"

# Imagen que encaja con cada tipo de parte.
TEMPLATE_IMAGES = {
    "Instalación de red": "rack_red.png",
    "Mantenimiento preventivo": "rack_red.png",
    "Instalación Wi-Fi": "rack_red.png",
    "Sustitución de router": "rack_red.png",
    "Avería eléctrica": "cuadro_electrico.png",
    "Instalación de SAI": "cuadro_electrico.png",
    "Cambio de iluminación": "paneles_led.png",
}


def write_voice_note() -> None:
    """Tres segundos de tonos suaves, como una nota de voz de prueba."""
    rate = 16000
    frames = bytearray()
    notes = [(440, 0.35), (0, 0.1), (554, 0.35), (0, 0.1), (659, 0.6), (0, 0.2), (554, 0.3), (440, 0.8)]
    for freq, seconds in notes:
        count = int(rate * seconds)
        for i in range(count):
            fade = min(1.0, i / 400, (count - i) / 400)
            value = int(9000 * fade * math.sin(2 * math.pi * freq * i / rate)) if freq else 0
            frames += value.to_bytes(2, "little", signed=True)
    DEMO_FILES_DIR.mkdir(parents=True, exist_ok=True)
    with wave.open(str(DEMO_FILES_DIR / "nota_voz.wav"), "wb") as out:
        out.setnchannels(1)
        out.setsampwidth(2)
        out.setframerate(rate)
        out.writeframes(bytes(frames))


def attach_demo_files(rnd: random.Random, reports) -> None:
    """Añade fotos y notas de voz a algunos partes ya empezados."""
    sizes = {f.name: f.stat().st_size for f in DEMO_FILES_DIR.glob("*.*")}
    next_id = 1
    for report in reports:
        files = []
        image = TEMPLATE_IMAGES.get(report["name"])
        if report["status"] >= 2 and image and image in sizes and rnd.random() < 0.6:
            files.append({"name": f"foto_{report['code'].lower()}.png", "type": "image", "asset": image})
        if report["status"] >= 2 and rnd.random() < 0.25:
            files.append({"name": f"nota_{report['code'].lower()}.wav", "type": "audio", "asset": "nota_voz.wav"})
        for f in files:
            f["id"] = next_id
            f["size"] = sizes[f["asset"]]
            next_id += 1
        report["files"] = [{"id": f.pop("id"), **f} for f in files]


def write(name: str, payload) -> None:
    path = API_DIR / name
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    print(f"  {path.relative_to(ROOT)}")


def main() -> None:
    rnd = random.Random(SEED)
    API_DIR.mkdir(parents=True, exist_ok=True)

    users = [
        {
            "id": u["id"],
            "name": u["name"],
            "email": u["email"],
            "password": DEMO_PASSWORD,
            "roles": [{"name": u["role"]}],
            # Ficha de técnico del usuario (el personal interno son los técnicos 1-5).
            "worker_id": u["id"] if u["id"] in STAFF_IDS else None,
        }
        for u in USERS
    ]
    records = build_records(rnd)
    incidents = build_incidents(rnd, records)

    print("Generando backend estático:")
    write("users.json", {"success": True, "data": users})
    write("company.json", {
        "success": True,
        "data": {
            "id": 1,
            "name": "ERP Flutter Demo",
            "legal_name": "ERP Flutter Demo S.L.",
            "vat": "B00000000",
            "city": "Valencia",
        },
    })
    write("clock_in_records.json", {"success": True, "data": records})
    write("clock_in_incidents.json", {"success": True, "data": incidents})
    write("messages.json", {"success": True, "data": build_messages()})
    write("holidays.json", {
        "success": True,
        "data": {
            "annual_allowance": ANNUAL_ALLOWANCE,
            "national_holidays": NATIONAL_HOLIDAYS,
            "company_holidays": COMPANY_HOLIDAYS,
            "periods": build_holidays(rnd),
        },
    })
    # Generador aparte para no alterar los datos ya existentes.
    clients_rnd = random.Random(SEED + 1)
    clients = build_clients(clients_rnd)
    documents = build_client_documents(clients_rnd, clients)
    write("clients.json", {"success": True, "data": clients})
    write("client_documents.json", {"success": True, "data": documents})
    visits = build_visit_reports(random.Random(SEED + 2), clients)
    write("workers.json", {"success": True, "data": build_workers()})
    write("visit_reports.json", {"success": True, "data": visits})
    work_reports = build_work_reports(random.Random(SEED + 3), clients)
    write_voice_note()
    attach_demo_files(random.Random(SEED + 4), work_reports)
    write("products.json", {"success": True, "data": build_products()})
    write("work_reports.json", {"success": True, "data": work_reports})
    print(f"{len(records)} fichajes, {len(incidents)} incidencias, {len(clients)} clientes, "
          f"{sum(len(d) for d in documents.values())} documentos, {len(visits)} visitas, {len(work_reports)} partes de trabajo.")


if __name__ == "__main__":
    main()
