# Informe de auditoría IAM

**Organización:** Mirador de Montepinar S.L.

**Laboratorio:** Lab 05 - Identity Governance & Access Reviews

**Fecha de generación:** 2026-10-28 09:14:32

## 1. Resumen ejecutivo

| Indicador | Resultado |
|---|---:|
| Usuarios inventariados | 14 |
| Asignaciones revisadas | 24 |
| Accesos esperados | 14 |
| Accesos no esperados | 10 |
| Asignaciones de cuentas inactivas | 2 |
| Usuarios inexistentes en asignaciones | 0 |
| Identificadores de usuario duplicados | 0 |

## 2. Accesos no esperados

| Usuario | Grupo | Estado | Criticidad | Recomendación |
|---|---|---|---|---|
| epastor | GRP-AtencionVecino | Activo | Media | Solicitar validacion al responsable del recurso |
| jmaroto | GRP-Administracion | Activo | Media | Solicitar validacion al responsable del recurso |
| arivas | GRP-Operaciones | Activo | Media | Solicitar validacion al responsable del recurso |
| mangulo | GRP-Finanzas | Activo | Media | Solicitar validacion al responsable del recurso |
| vmaroto | GRP-Operaciones | Inactivo | Alta | Validar la baja y revisar la retirada de permisos |
| vmaroto | GRP-Sistemas | Inactivo | Alta | Validar la baja y revisar la retirada de permisos |
| bescobar | GRP-Finanzas | Activo | Media | Solicitar validacion al responsable del recurso |
| rparrales | GRP-Administracion | Activo | Media | Solicitar validacion al responsable del recurso |
| rvillanueva | GRP-AtencionVecino | Activo | Media | Solicitar validacion al responsable del recurso |
| nchacon | GRP-Sistemas | Activo | Media | Solicitar validacion al responsable del recurso |

## 3. Asignaciones de cuentas inactivas

| Usuario | Grupo | Criticidad | Recomendación |
|---|---|---|---|
| vmaroto | GRP-Operaciones | Alta | Confirmar la baja y revisar la retirada del acceso |
| vmaroto | GRP-Sistemas | Alta | Confirmar la baja y revisar la retirada del acceso |

## 4. Recomendaciones

- Validar los accesos no esperados con los responsables de cada recurso.
- Revisar las asignaciones de las cuentas inactivas y confirmar si procede retirar sus permisos.
- Mantener actualizada la matriz de accesos esperados.
- Registrar la aprobación y las acciones correctivas en un proceso de revisión de accesos.

## 5. Alcance y limitaciones

Esta auditoría utiliza datos CSV ficticios y una matriz de accesos esperados definida para el laboratorio.
Un acceso no esperado es un hallazgo que requiere validación; no demuestra por sí solo que exista una infracción.
El script no modifica cuentas ni permisos.
