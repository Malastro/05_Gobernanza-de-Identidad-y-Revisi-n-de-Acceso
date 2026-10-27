# 05_Gobernanza-de-Identidad-y-Revisi-n-de-Acceso

### 1. Descripción del proyecto

Tras desplegar la infraestructura de identidad híbrida, configurar MFA y automatizar el ciclo de vida de las identidades, la comunidad de Mirador de Montepinar SL se enfrenta a un nuevo problema: nadie parece tener claro quién debería conservar acceso a qué.

Antonio Recio, presidente de la comunidad y defensor de que cada vecino se ocupe de sus propios asuntos —preferiblemente sin tocar los suyos—, ha solicitado una auditoría de los permisos existentes. Amador Rivas conserva accesos de dudosa necesidad, Rosario Parrales acumula asignaciones que deben revisarse y hasta Vicente Maroto, que figura como inactivo, sigue apareciendo en el inventario de accesos.

Ante semejante descontrol, se pone en marcha la Operación Junta de Vecinos, un laboratorio de Identity Governance orientado a revisar asignaciones, detectar accesos innecesarios y documentar decisiones de acceso mediante PowerShell y archivos CSV.

El objetivo es construir un proceso reproducible que compare los permisos actuales con una matriz de acceso esperado, identifique posibles desviaciones y permita simular la retirada de accesos antes de aplicar cualquier cambio.

Objetivos técnicos

- Construir un inventario ficticio de usuarios, grupos y asignaciones de acceso.
- Definir una matriz de acceso esperado según el departamento y el estado de cada identidad.
- Detectar asignaciones que requieran revisión por exceso de privilegios, cambios organizativos o inactividad.
- Registrar las decisiones de revisión y sus justificaciones.
- Simular la remediación de accesos mediante PowerShell, sin modificar directorios reales.
- Generar informes CSV que permitan comparar el estado inicial y el resultado de la revisión.
- Documentar las pruebas, las limitaciones y las medidas de seguridad del proceso.

