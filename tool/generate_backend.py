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
import random
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
    write("holidays.json", {
        "success": True,
        "data": {
            "annual_allowance": ANNUAL_ALLOWANCE,
            "national_holidays": NATIONAL_HOLIDAYS,
            "company_holidays": COMPANY_HOLIDAYS,
            "periods": build_holidays(rnd),
        },
    })
    print(f"{len(records)} fichajes, {len(incidents)} incidencias.")


if __name__ == "__main__":
    main()
