# ERP Flutter

App móvil de demostración para la gestión de personal en movilidad: fichaje, incidencias, vacaciones, partes de trabajo, clientes, visitas y mensajería, con permisos por rol.

Todos los datos (empresa, usuarios, fichajes...) son **ficticios**. El backend es un conjunto de ficheros JSON estáticos que se pueden publicar en GitHub Pages.

## Ejecutar

```bash
flutter pub get
flutter run            # Android / iOS / macOS
flutter run -d chrome  # Web
flutter test
```

En el login, usa como servidor `demo` (datos empaquetados en la app) o la URL donde hayas publicado `backend/`. Cuentas (contraseña `demo1234`); también se rellenan desde «Cuentas de demostración»:

| Correo | Rol | Ve |
|---|---|---|
| superadmin@erpflutter.dev | Superadmin | Todo, fichajes y vacaciones de toda la plantilla |
| admin@erpflutter.dev | Admin | Todo, fichajes y vacaciones de toda la plantilla |
| usuario@erpflutter.dev | Usuario | Sus fichajes, partes, vacaciones, mensajes |
| trabajador@erpflutter.dev | Trabajador | Sus fichajes, partes, vacaciones, mensajes |
| cliente@erpflutter.dev | Cliente | Mensajes |
| proveedor@erpflutter.dev | Proveedor | Mensajes |

La mensajería es un chat abierto: cualquier usuario puede escribir a cualquier otro, sea cual sea su rol.

## Estado de los módulos

| Módulo | Estado |
|---|---|
| Splash, login (URL configurable, recordar URL/usuario, ES/VAL/CAT/EN) | ✅ |
| Shell con menú lateral, roles y permisos, modo oscuro | ✅ |
| Inicio: reloj, fichaje entrada/salida con confirmación | ✅ |
| Fichajes: por mes o rango, agrupar por empleado, ubicación, reportar incidencia | ✅ |
| Incidencias: listado, agrupación, detalle | ✅ |
| Vacaciones: lista anual y calendario, resumen, solicitar/cancelar (trabajador), aprobar/rechazar (gestión) | ✅ |
| Mensajería: conversaciones, chat con sondeo periódico, nuevo mensaje, botón flotante con no leídos | ✅ |
| Clientes (gestión): buscador, ficha, presupuestos, pedidos, albaranes, facturas y recurrentes con detalle | ✅ |
| Partes de visita (gestión): elegir empresa, visitas por mes/rango/búsqueda, detalle y alta con técnicos | ✅ |
| Partes de trabajo: activos/finalizados, búsqueda, fechas, agrupar por empresa (gestión), detalle, añadir líneas con productos y precio de catálogo editable, editar cualquier línea (el precio de catálogo del producto no cambia), total del parte, firma del cliente. El trabajador solo ve sus partes | ✅ |
| Archivos de los partes: fotos (cámara/galería), notas de voz (grabar/reproducir), eliminar, máx. 10 MB | ✅ |

## Backend estático

```
backend/
├── index.html                    # Portada con los endpoints
└── api/
    ├── users.json
    ├── company.json
    ├── clock_in_records.json
    ├── clock_in_incidents.json
    ├── messages.json              # conversaciones, mensajes y respuestas automáticas
    ├── holidays.json              # festivos, cupo anual y períodos
    ├── clients.json               # fichas de clientes (direcciones, contactos, pago)
    ├── client_documents.json      # documentos por tipo, con líneas y totales
    ├── workers.json               # técnicos asignables a visitas y trabajos
    ├── visit_reports.json         # partes de visita por cliente
    ├── products.json              # catálogo para las líneas de los partes
    └── work_reports.json          # partes de trabajo con líneas, técnicos y firmas
```

- Se genera con `python3 tool/generate_backend.py`.
- Las fotos de ejemplo de los partes son ilustraciones dibujadas con `flutter test tool/render_demo_files_test.dart` (en `assets/demo_files/`); la nota de voz la genera el script de Python.
- Los archivos que adjunta el usuario se guardan en la carpeta de la app (móvil y escritorio) o en el almacenamiento del navegador (web, con espacio limitado).
- Las fechas se guardan como `workday_offset` (días laborables antes de hoy) + hora. La app las convierte al día actual, así la demo siempre muestra actividad reciente.
- En mensajería, al enviar un mensaje el destinatario "contesta" a los pocos segundos con una respuesta de `auto_replies`; el sondeo periódico del chat la recoge como un mensaje real.
- Como el servidor es de solo lectura, lo que en una API real sería un `POST` (fichar, crear incidencias, solicitar o aprobar vacaciones, enviar mensajes, crear visitas, añadir líneas, firmar partes, adjuntar archivos) se guarda en el dispositivo y se mezcla con los datos del servidor.

**Publicar en GitHub Pages:** el workflow [`.github/workflows/backend-pages.yml`](.github/workflows/backend-pages.yml) publica la carpeta `backend/` cada vez que se hace push a `main` con cambios en ella (o a mano desde la pestaña Actions). Hay que activarlo una vez en *Settings → Pages → Source: GitHub Actions*. Después se escribe en la app la URL `https://raulesteveza.github.io/Erp_Flutter_Demo`; la app pide `<url>/api/<recurso>.json`.

## Arquitectura

```
lib/
├── core/        # tema, branding (logo vectorial), roles, sesión, red, widgets comunes
├── data/        # repositorios + cambios locales
├── domain/      # modelos
├── features/    # splash, auth, shell, home, attendance, incidents, holidays, messaging, clients, visit_reports, work_reports
└── l10n/        # ARB (es, en, ca, ca_ES)
```

ViewModels `ChangeNotifier` + `ListenableBuilder`. Los listados por período comparten `PeriodListViewModel` y `PeriodListScaffold`.

## Icono

El logo se dibuja en vectorial (`lib/core/branding/erp_logo.dart`). Para regenerar los iconos de la app:

```bash
flutter test tool/render_app_icon_test.dart
dart run flutter_launcher_icons
```
