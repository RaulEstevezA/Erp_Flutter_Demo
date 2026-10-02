# ERP Flutter · Demo web de una app ERP en producción

> [!IMPORTANT]
> **Esta es la demo pública de una aplicación real.**
> La app original la desarrollé durante mis prácticas en **Microvalencia Soluciones Informáticas** y la usa la empresa con su ERP. Su código es propiedad de la empresa y no es público.
>
> Este repositorio es una **reimplementación desde cero** para poder enseñarla: misma funcionalidad, navegación y diseño de pantallas, pero con otro nombre, otros colores, otro logo, **datos inventados** y un backend estático en lugar de la API Laravel. No contiene código ni datos de Microvalencia.

**Demo en vivo:** [raulesteveza.github.io/demos/ERP_Flutter](https://raulesteveza.github.io/demos/ERP_Flutter/)\
**Vídeo de la app real:** [youtu.be/lrgRXaBEdI4](https://youtu.be/lrgRXaBEdI4)\
**Ficha del proyecto:** [Proyectos](https://raulesteveza.github.io/projects.html) · [Experiencia](https://raulesteveza.github.io/experience.html)

<p align="center">
  <img src="img/login.png" alt="Pantalla de inicio de sesión" width="180" />
  &nbsp;
  <img src="img/main.png" alt="Inicio de una usuaria administradora" width="180" />
  &nbsp;
  <img src="img/holidays_black.png" alt="Vacaciones de un trabajador en modo oscuro" width="180" />
</p>

---

## Índice

- [El proyecto real](#el-proyecto-real)
- [Esta demo](#esta-demo)
- [Cómo probarla](#cómo-probarla)
- [Módulos](#módulos)
- [Roles y permisos](#roles-y-permisos)
- [Diferencias con la app real](#diferencias-con-la-app-real)
- [Backend estático](#backend-estático)
- [Arquitectura](#arquitectura)
- [Ejecutar en local](#ejecutar-en-local)
- [Tests](#tests)
- [Despliegue](#despliegue)
- [Aviso legal](#aviso-legal)

---

## El proyecto real

**Empresa:** Microvalencia Soluciones Informáticas S.L.\
**Puesto:** Desarrollador de Software (prácticas) · marzo – junio 2026 · 383 h\
**Estado:** en producción · versión 2.3.7 · la empresa prepara su publicación en Google Play Store y App Store

### Objetivo

Llevar al teléfono parte del trabajo diario del ERP de la empresa, para que el personal pueda usarlo en movilidad **sin sustituir al sistema principal**. La app consume, mediante APIs REST, usuarios, permisos, clientes, fichajes, partes de trabajo, visitas, vacaciones, documentos y mensajería.

El alcance lo marcó la empresa. Técnicamente se podían añadir muchas más funciones, pero no se buscaba que el móvil tuviera autonomía total sobre el ERP: la app es un **apoyo para el día a día** de los trabajadores que ya lo usan. Por eso algunas acciones se quedan, a propósito, en el ERP de escritorio; por ejemplo, la descripción y las observaciones de los partes de trabajo se consultan desde el móvil pero no se editan.

### Las dos partes del stack

- **App móvil (Flutter):** la diseñé y desarrollé completa.
- **Backend (Laravel/PHP):** diseñé e implementé desde cero aproximadamente el **90 % de los controladores y rutas de la API** que consume la app. Son endpoints específicos para móvil, con respuestas optimizadas, validaciones, permisos por perfil y formatos adaptados al consumo desde Flutter.

Empecé sin experiencia previa en Flutter, PHP ni Laravel: los tres los aprendí y apliqué en este proyecto en producción.

### Funcionalidades

- Autenticación con **URL de servidor configurable**, opciones para recordar la URL y el usuario, restauración automática de sesión y cierre seguro.
- **Fichaje** de entrada y salida con ubicación GPS opcional, historial mensual y vista agrupada por empleado para administradores.
- **Incidencias de fichaje:** creación, detalle y seguimiento del estado.
- **Mensajería interna** con sondeo periódico y contador de mensajes no leídos.
- **Partes de trabajo** con líneas, grabación de audio, imágenes adjuntas y **firma digital del cliente**.
- **Partes de visita** vinculados a clientes, con distancia y tiempo de desplazamiento opcionales.
- **Clientes:** búsqueda, ficha, cinco tipos de documento (presupuestos, pedidos, albaranes, facturas y facturas recurrentes) y apertura de direcciones en Maps.
- **Vacaciones** con calendario visual, solicitud, aprobación, rechazo y cancelación.
- **Control de acceso por roles** con seis perfiles: superadmin, admin, usuario, trabajador, cliente y proveedor.
- **Internacionalización** en español, valenciano, catalán e inglés, y tema claro/oscuro.

### Aspectos técnicos

- Organización **por funcionalidades** con arquitectura **MVVM** y principios **SOLID**: ViewModels por módulo, estado inmutable y separación estricta de capas.
- **Manejo de errores en tres capas** (excepción de red → excepción de dominio → mensaje de interfaz localizado), con 15 tipos de error: desde problemas de certificado SSL y tiempos de espera hasta credenciales incorrectas o servidor caído.
- **Sesión cifrada** con el almacenamiento seguro del dispositivo (FlutterSecureStorage), con una solución específica para el Keystore de los móviles Xiaomi/MIUI.
- **Detección de caída del servidor** en tiempo real: bloquea la navegación de forma controlada para no dejar pantallas a medias.
- El inicio y el menú calculan qué módulos ve cada rol a partir de la **sesión guardada en el dispositivo**, así que la navegación está disponible aunque el servidor no responda al arrancar.
- Gestión del **gesto atrás** de Android y ajuste del margen inferior en dispositivos con navegación por gestos.
- **Dos variantes de producción** (completa y *lite*) desde el mismo código mediante **Flutter Flavors**. La *lite* deja solo fichajes, incidencias y vacaciones.
- El **sondeo del chat** solo avisa a la interfaz si cambian el número de mensajes o el último, para no redibujar sin motivo.
- **Documentación técnica**, **changelog** y **versionado semántico** (16 entregas hasta la 2.3.7). Pruebas en dispositivos reales y emuladores, con ajustes para distintos tamaños de pantalla y versiones de Android.

**Tecnologías:** Flutter, Dart, PHP, Laravel, REST API, MVVM, SOLID, Dio, FlutterSecureStorage, Geolocator, Flutter Flavors.

---

## Esta demo

Para enseñar la app sin depender del ERP de la empresa, la reescribí entera en este repositorio:

1. **Reimplementación limpia.** El código está escrito de nuevo; la app original solo se usó como referencia de funcionalidad y diseño.
2. **Otra identidad.** Nombre *ERP Flutter*, colores índigo, violeta y turquesa, y un logo vectorial propio.
3. **Datos inventados.** La empresa, los usuarios, los clientes, los documentos, los partes, las fotos y los mensajes son ficticios.
4. **Backend estático.** La API Laravel se sustituye por ficheros JSON generados por un script. Lo que en la API sería una escritura (fichar, firmar, añadir una línea...) se guarda en el dispositivo.
5. **Siempre actual.** Las fechas se guardan relativas a hoy, así que la demo muestra actividad reciente aunque los JSON se generaran hace meses.
6. **Funciona en el navegador** y en Android, iOS y macOS. La versión web se publica automáticamente en mi web.

## Cómo probarla

Abre la [demo en vivo](https://raulesteveza.github.io/demos/ERP_Flutter/) o ejecútala en local. En el login, el servidor `demo` ya viene puesto y la cuenta se puede elegir en **«Cuentas de demostración»**. La contraseña de todas es `demo1234`.

| Cuenta | Rol | Qué ve |
|---|---|---|
| `superadmin@erpflutter.dev` | Superadmin | Todo: fichajes, vacaciones y partes de toda la plantilla, clientes y visitas |
| `admin@erpflutter.dev` | Admin | Igual que superadmin |
| `usuario@erpflutter.dev` | Usuario | Sus fichajes, incidencias, vacaciones y los partes en los que está asignado |
| `trabajador@erpflutter.dev` | Trabajador | Igual que usuario |
| `cliente@erpflutter.dev` | Cliente | Mensajería |
| `proveedor@erpflutter.dev` | Proveedor | Mensajería |

Algunas cosas que se pueden hacer:

- **Fichar** desde el inicio y ver el registro con su ubicación en *Ver fichajes*.
- **Pedir vacaciones** como trabajador y **aprobarlas** como admin.
- **Escribir un mensaje** a cualquier usuario: el destinatario «contesta» a los pocos segundos.
- **Abrir un parte de trabajo**, añadir líneas del catálogo (la mano de obra se cobra por horas según los minutos), cambiar su precio, adjuntar fotos o notas de voz y **firmar**.
- **Restablecer los datos** desde el menú lateral para volver al estado inicial.

## Módulos

| Módulo | Contenido |
|---|---|
| **Inicio** | Reloj en directo, botón de fichaje con confirmación, accesos a los módulos del rol y botón flotante de mensajes con no leídos |
| **Fichajes** | Por mes o rango de fechas, agrupados por empleado (gestión), ubicación en Maps y aviso de incidencia desde un registro |
| **Incidencias** | Listado por período, agrupación por empleado y detalle con estado |
| **Vacaciones** | Lista anual y calendario, resumen de días, solicitud y cancelación (personal), aprobación y rechazo (gestión) |
| **Mensajería** | Conversaciones, chat con sondeo periódico, nuevo mensaje con buscador de destinatarios y contador de no leídos |
| **Clientes** | Buscador, ficha (direcciones, contactos, pago) y cinco tipos de documento con líneas y totales |
| **Partes de visita** | Selección de empresa, visitas por mes, rango o búsqueda, detalle y alta con técnicos y desplazamiento |
| **Partes de trabajo** | Activos y finalizados, búsqueda, fechas, agrupación por empresa, líneas con productos y precios, archivos (cámara, galería y audio) y firma del cliente |

## Roles y permisos

Los permisos están en una única matriz ([`permissions.dart`](lib/core/roles/permissions.dart)). Cada módulo se muestra o se oculta según ella, y los repositorios vuelven a comprobarlos: aunque alguien llegara a una pantalla, no obtendría datos que no le corresponden.

| Permiso | Superadmin / Admin | Usuario / Trabajador | Cliente / Proveedor |
|---|:---:|:---:|:---:|
| Fichar y ver sus fichajes | ✅ | ✅ | |
| Ver fichajes de toda la plantilla | ✅ | | |
| Vacaciones: solicitar | | ✅ | |
| Vacaciones: ver todas y aprobar | ✅ | | |
| Partes de trabajo: los suyos | ✅ | ✅ | |
| Partes de trabajo: todos | ✅ | | |
| Clientes y partes de visita | ✅ | | |
| Mensajería | ✅ | ✅ | ✅ |

## Diferencias con la app real

| | App real (Microvalencia) | Esta demo |
|---|---|---|
| Backend | API REST Laravel/PHP sobre el ERP | JSON estáticos generados por un script |
| Escrituras | Se guardan en el ERP | Se guardan en el dispositivo; se pueden restablecer |
| Datos | Los de la empresa | Inventados |
| Identidad | Marca de Microvalencia | *ERP Flutter*: otros colores y logo |
| Red y sesión | Dio, FlutterSecureStorage, detección de caída del servidor | `http`, SharedPreferences, latencia simulada |
| Ubicación | GPS real (Geolocator) | Coordenadas simuladas |
| Variantes | Completa y *lite* (Flutter Flavors) | Una sola |
| Mensajes | Mensajes con archivo adjunto | Solo texto, con respuestas automáticas |
| Archivos | Se suben al ERP | Carpeta de la app (móvil y escritorio) o navegador (web) |

En la demo hay también algunos añadidos que no están en la app real: precio de catálogo en las líneas de los partes (editable línea a línea), mano de obra calculada por horas a partir de los minutos, total del parte y el botón para restablecer los datos.

## Backend estático

```
backend/
├── index.html                 Portada con los endpoints
└── api/
    ├── users.json             Usuarios y roles
    ├── company.json           Empresa
    ├── clock_in_records.json  Fichajes
    ├── clock_in_incidents.json
    ├── holidays.json          Vacaciones, festivos y cupo anual
    ├── messages.json          Conversaciones, mensajes y respuestas automáticas
    ├── clients.json           Clientes con direcciones, contactos y pago
    ├── client_documents.json  Presupuestos, pedidos, albaranes y facturas
    ├── visit_reports.json     Partes de visita
    ├── workers.json           Técnicos
    ├── products.json          Catálogo con precios
    └── work_reports.json      Partes de trabajo con líneas, archivos y firmas
```

- **Generación:** `python3 tool/generate_backend.py`. Usa una semilla fija, así que siempre produce los mismos datos.
- **Fechas relativas:** se guardan como días laborables antes de hoy más una hora, y la app las convierte al abrirse.
- **Servidor `demo`:** lee los JSON incluidos en la app. Con una URL, los pide a `<url>/api/<recurso>.json`, por ejemplo `https://raulesteveza.github.io/demos/ERP_Flutter`.
- **Archivos de ejemplo:** las fotos de los partes son ilustraciones dibujadas con `flutter test tool/render_demo_files_test.dart`; la nota de voz la genera el script de Python.

## Arquitectura

```
lib/
├── core/       Tema, logo, roles y permisos, sesión, red, inyección de dependencias,
│               widgets y ViewModels base reutilizables
├── data/       Repositorios (uno por módulo) y almacenamiento local
├── domain/     Modelos
├── features/   Una carpeta por módulo: pantallas, ViewModels y widgets propios
└── l10n/       Traducciones (es, en, ca y valenciano)
```

- **MVVM** con `ChangeNotifier` y `ListenableBuilder`, sin paquetes de estado externos.
- **Repositorios** que aplican las reglas de negocio y de permisos, independientes de las pantallas.
- **ViewModels base** para los listados con período, búsqueda, paginación infinita y descarte de respuestas obsoletas.
- **Almacenamiento de archivos** con una implementación por plataforma (ficheros o navegador) mediante imports condicionales.
- **Internacionalización** con `gen-l10n` y el valenciano como variante del catalán.

## Ejecutar en local

Requiere Flutter 3.47 o superior.

```bash
flutter pub get
flutter run            # Android, iOS o macOS
flutter run -d chrome  # Web
```

Para verla exactamente como se publica (página con el marco de móvil, la app en `app/` y el backend en `api/`):

```bash
flutter build web --release --base-href /demos/ERP_Flutter/app/

mkdir -p /tmp/site/demos/ERP_Flutter
cp -R showcase/. /tmp/site/demos/ERP_Flutter/
cp -R build/web /tmp/site/demos/ERP_Flutter/app
cp -R backend/api /tmp/site/demos/ERP_Flutter/api
cp backend/index.html /tmp/site/demos/ERP_Flutter/backend.html
cd /tmp/site && python3 -m http.server 8000
# Abrir http://localhost:8000/demos/ERP_Flutter/
```

Para regenerar los iconos de la app a partir del logo vectorial:

```bash
flutter test tool/render_app_icon_test.dart
dart run flutter_launcher_icons
```

## Tests

```bash
flutter test
```

Hay 49 tests. Cubren los permisos de cada rol, el calendario laboral, el fichaje, las vacaciones, la mensajería, los clientes, las visitas y los partes de trabajo (líneas, precios, mano de obra por horas, firma, archivos y restablecimiento). También hay recorridos de pantallas a tamaño de móvil.

## Despliegue

El workflow [`deploy-demo.yml`](.github/workflows/deploy-demo.yml) se ejecuta en cada push a `main` y también se puede lanzar a mano desde *Actions*:

1. Ejecuta `flutter analyze` y `flutter test`.
2. Compila la app web para la ruta `/demos/ERP_Flutter/app/`.
3. Publica en `demos/ERP_Flutter/` del repositorio [RaulEstevezA.github.io](https://github.com/RaulEstevezA/RaulEstevezA.github.io):

| Ruta | Contenido |
|---|---|
| `demos/ERP_Flutter/` | Página de presentación con la app en un marco de móvil ([`showcase/`](showcase/index.html)) |
| `demos/ERP_Flutter/app/` | App web |
| `demos/ERP_Flutter/api/` | Backend estático |
| `demos/ERP_Flutter/backend.html` | Portada del backend |

Necesita el secreto de Actions `PORTFOLIO_DEPLOY_TOKEN`: un token *fine-grained* con permiso **Contents: Read and write** solo sobre `RaulEstevezA.github.io`. La carpeta `demos/ERP_Flutter/` de la web se sustituye entera en cada despliegue, así que no debe editarse a mano.

## Aviso legal

La aplicación original, su código y sus datos son propiedad de **Microvalencia Soluciones Informáticas S.L.** Este repositorio no contiene nada de ella: es una reimplementación independiente con fines de portfolio, con identidad visual y datos inventados. Las ilustraciones de ejemplo están dibujadas para esta demo.

## Desarrollador

**Raul Estevez**

- [Web personal](https://raulesteveza.github.io/)
- [LinkedIn](https://www.linkedin.com/in/raulesteveza/)

[Volver al README principal](./README.md)
