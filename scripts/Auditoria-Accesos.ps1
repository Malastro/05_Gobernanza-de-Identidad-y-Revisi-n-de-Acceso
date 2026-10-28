
# ============================================================
# Lab 05 - Identity Governance & Access Reviews
# Organizacion: Mirador de Montepinar S.L.
# Objetivo: auditar asignaciones de acceso usando CSV
# ============================================================

$ErrorActionPreference = "Stop"

# Obtener la ruta raiz del proyecto a partir de este script
$rutaProyecto = Split-Path -Parent $PSScriptRoot

# Definir las rutas de entrada
$rutaUsuarios = Join-Path $rutaProyecto "data\usuarios.csv"
$rutaAsignaciones = Join-Path $rutaProyecto "data\asignaciones.csv"
$rutaEsperados = Join-Path $rutaProyecto "data\accesos_esperados.csv"

# Definir la carpeta de informes
$rutaInformes = Join-Path $rutaProyecto "reports"

Write-Host "=============================================="
Write-Host " Lab 05 - Auditoria de accesos"
Write-Host " Mirador de Montepinar S.L."
Write-Host "=============================================="
Write-Host "Proyecto: $rutaProyecto"

# Comprobar que existen los archivos de entrada
$archivosEntrada = @(
    $rutaUsuarios
    $rutaAsignaciones
    $rutaEsperados
)

foreach ($archivo in $archivosEntrada) {
    if (-not (Test-Path -LiteralPath $archivo -PathType Leaf)) {
        throw "No se encuentra el archivo requerido: $archivo"
    }
}

# ============================================================
# Validar las columnas requeridas en los archivos CSV
# ============================================================

$esquemasEsperados = @{
    "usuarios.csv" = @(
        "UserId", "Nombre", "Departamento", "Estado"
    )
    "asignaciones.csv" = @(
        "UserId", "Grupo"
    )
    "accesos_esperados.csv" = @(
        "UserId", "GrupoEsperado"
    )
}

foreach ($nombreArchivo in $esquemasEsperados.Keys) {

    $rutaArchivo = Join-Path `
        (Join-Path $rutaProyecto "data") `
        $nombreArchivo

    $registros = @(Import-Csv -LiteralPath $rutaArchivo)

    # Comprobar que el archivo contiene registros
    if ($registros.Count -eq 0) {
        throw "El archivo '$nombreArchivo' está vacío o no contiene datos."
    }

    # Obtener los nombres de las columnas
    $columnas = @(
        $registros[0].PSObject.Properties.Name
    )

    # Identificar las columnas que faltan
    $columnasFaltantes = @(
        $esquemasEsperados[$nombreArchivo] |
            Where-Object { $_ -notin $columnas }
    )

    # Detener el script si falta alguna columna obligatoria
    if ($columnasFaltantes.Count -gt 0) {
        throw "El archivo '$nombreArchivo' no contiene las columnas requeridas: $($columnasFaltantes -join ', ')."
    }

    Write-Host "Columnas validadas: $nombreArchivo"
}

# Crear la carpeta de informes si no existe
if (-not (Test-Path -LiteralPath $rutaInformes -PathType Container)) {
    New-Item -ItemType Directory -Path $rutaInformes | Out-Null
}

Write-Host "Validacion de archivos completada."


# ============================================================
# 1. Importar los datos del laboratorio
# ============================================================

Write-Host "`n[1/4] Importando archivos CSV..."

$usuarios = @(Import-Csv -LiteralPath $rutaUsuarios)
$asignaciones = @(Import-Csv -LiteralPath $rutaAsignaciones)
$esperados = @(Import-Csv -LiteralPath $rutaEsperados)

Write-Host "Usuarios inventariados: $($usuarios.Count)"
Write-Host "Asignaciones actuales: $($asignaciones.Count)"
Write-Host "Accesos esperados: $($esperados.Count)"

# ============================================================
# 2. Validar la integridad de los datos
# ============================================================

Write-Host "`n[2/4] Validando la integridad de los datos..."

# Comprobar que todas las asignaciones apuntan a usuarios existentes
$idsUsuarios = @($usuarios | ForEach-Object { $_.UserId })

$asignacionesSinUsuario = @(
    $asignaciones | Where-Object {
        $_.UserId -notin $idsUsuarios
    }
)

$esperadosSinUsuario = @(
    $esperados | Where-Object {
        $_.UserId -notin $idsUsuarios
    }
)

# Detectar identificadores de usuario duplicados
$usuariosDuplicados = @(
    $usuarios |
        Group-Object UserId |
        Where-Object { $_.Count -gt 1 }
)

# Detectar asignaciones duplicadas
$asignacionesDuplicadas = @(
    $asignaciones |
        Group-Object UserId, Grupo |
        Where-Object { $_.Count -gt 1 }
)

# Detectar accesos esperados duplicados
$esperadosDuplicados = @(
    $esperados |
        Group-Object UserId, GrupoEsperado |
        Where-Object { $_.Count -gt 1 }
)

Write-Host "Asignaciones con usuarios inexistentes: $($asignacionesSinUsuario.Count)"
Write-Host "Accesos esperados con usuarios inexistentes: $($esperadosSinUsuario.Count)"
Write-Host "Identificadores de usuario duplicados: $($usuariosDuplicados.Count)"
Write-Host "Asignaciones duplicadas: $($asignacionesDuplicadas.Count)"
Write-Host "Accesos esperados duplicados: $($esperadosDuplicados.Count)"

# ============================================================
# 3. Auditar las asignaciones de acceso
# ============================================================

Write-Host "`n[3/4] Auditando asignaciones de acceso..."

# Identificar asignaciones que no aparecen en la matriz de accesos esperados
$accesosNoEsperados = @(
    $asignaciones | Where-Object {
        $asignacionActual = $_

        -not (
            $esperados | Where-Object {
                $_.UserId -eq $asignacionActual.UserId -and
                $_.GrupoEsperado -eq $asignacionActual.Grupo
            }
        )
    }
)

# Identificar asignaciones de usuarios cuyo estado es Inactivo
$accesosInactivos = @(
    $asignaciones | Where-Object {
        $asignacionActual = $_

        $usuarioActual = $usuarios | Where-Object {
            $_.UserId -eq $asignacionActual.UserId
        }

        $usuarioActual.Estado -eq "Inactivo"
    }
)

Write-Host "Accesos no esperados detectados: $($accesosNoEsperados.Count)"
Write-Host "Asignaciones de cuentas inactivas: $($accesosInactivos.Count)"

# ============================================================
# 4. Preparar y exportar los informes
# ============================================================

Write-Host "`nClasificando los hallazgos..."

# Enriquecer accesos no esperados
$hallazgosNoEsperados = @(
    foreach ($acceso in $accesosNoEsperados) {
        $usuario = $usuarios |
            Where-Object { $_.UserId -eq $acceso.UserId } |
            Select-Object -First 1

        $esInactivo = $usuario.Estado -eq "Inactivo"

        [PSCustomObject]@{
            UserId          = $acceso.UserId
            Grupo           = $acceso.Grupo
            EstadoUsuario   = $usuario.Estado
            TipoHallazgo    = if ($esInactivo) {
                "Acceso no esperado en cuenta inactiva"
            } else {
                "Acceso no esperado"
            }
            Criticidad      = if ($esInactivo) {
                "Alta"
            } else {
                "Media"
            }
            Recomendacion   = if ($esInactivo) {
                "Validar la baja y revisar la retirada de permisos"
            } else {
                "Solicitar validacion al responsable del recurso"
            }
        }
    }
)

# Enriquecer asignaciones de cuentas inactivas
$hallazgosInactivos = @(
    foreach ($acceso in $accesosInactivos) {
        [PSCustomObject]@{
            UserId        = $acceso.UserId
            Grupo         = $acceso.Grupo
            EstadoUsuario = "Inactivo"
            Criticidad    = "Alta"
            Recomendacion = "Confirmar la baja y revisar la retirada del acceso"
        }
    }
)

Write-Host "Hallazgos no esperados enriquecidos: $($hallazgosNoEsperados.Count)"
Write-Host "Hallazgos de cuentas inactivas enriquecidos: $($hallazgosInactivos.Count)"


Write-Host "`n[4/4] Generando informes..."


# Exportar los hallazgos enriquecidos
$hallazgosNoEsperados |
    Export-Csv -LiteralPath (Join-Path $rutaInformes "accesos_no_esperados.csv") `
        -NoTypeInformation -Encoding UTF8

$hallazgosInactivos |
    Export-Csv -LiteralPath (Join-Path $rutaInformes "accesos_cuentas_inactivas.csv") `
        -NoTypeInformation -Encoding UTF8


$resumen = [PSCustomObject]@{
    UsuariosInventariados          = $usuarios.Count
    AsignacionesRevisadas           = $asignaciones.Count
    AccesosEsperados                = $esperados.Count
    AccesosNoEsperados              = $accesosNoEsperados.Count
    AsignacionesCuentasInactivas    = $accesosInactivos.Count
    AsignacionesConUsuarioInexistente = $asignacionesSinUsuario.Count
    AccesosEsperadosConUsuarioInexistente = $esperadosSinUsuario.Count
    UsuariosDuplicados              = $usuariosDuplicados.Count
    AsignacionesDuplicadas           = $asignacionesDuplicadas.Count
    AccesosEsperadosDuplicados       = $esperadosDuplicados.Count
}

$resumen |
    Export-Csv -LiteralPath (Join-Path $rutaInformes "resumen_auditoria.csv") `
        -NoTypeInformation -Encoding UTF8

Write-Host "`n=============================================="
Write-Host " AUDITORIA FINALIZADA"
Write-Host "=============================================="
$resumen | Format-List

Write-Host "Informes guardados en: $rutaInformes"


# ============================================================
# 5. Generar informe Markdown
# ============================================================

Write-Host "`nGenerando informe Markdown..."

$rutaInformeMarkdown = Join-Path $rutaInformes "informe_auditoria.md"
$fechaInforme = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$lineasInforme = @(
    "# Informe de auditoría IAM"
    ""
    "**Organización:** Mirador de Montepinar S.L."
    ""
    "**Laboratorio:** Lab 05 - Identity Governance & Access Reviews"
    ""
    "**Fecha de generación:** $fechaInforme"
    ""
    "## 1. Resumen ejecutivo"
    ""
    "| Indicador | Resultado |"
    "|---|---:|"
    "| Usuarios inventariados | $($usuarios.Count) |"
    "| Asignaciones revisadas | $($asignaciones.Count) |"
    "| Accesos esperados | $($esperados.Count) |"
    "| Accesos no esperados | $($hallazgosNoEsperados.Count) |"
    "| Asignaciones de cuentas inactivas | $($hallazgosInactivos.Count) |"
    "| Usuarios inexistentes en asignaciones | $($asignacionesSinUsuario.Count) |"
    "| Identificadores de usuario duplicados | $($usuariosDuplicados.Count) |"
    ""
    "## 2. Accesos no esperados"
    ""
    "| Usuario | Grupo | Estado | Criticidad | Recomendación |"
    "|---|---|---|---|---|"
)

foreach ($hallazgo in $hallazgosNoEsperados) {
    $lineasInforme += "| $($hallazgo.UserId) | $($hallazgo.Grupo) | $($hallazgo.EstadoUsuario) | $($hallazgo.Criticidad) | $($hallazgo.Recomendacion) |"
}

$lineasInforme += @(
    ""
    "## 3. Asignaciones de cuentas inactivas"
    ""
    "| Usuario | Grupo | Criticidad | Recomendación |"
    "|---|---|---|---|"
)

foreach ($hallazgo in $hallazgosInactivos) {
    $lineasInforme += "| $($hallazgo.UserId) | $($hallazgo.Grupo) | $($hallazgo.Criticidad) | $($hallazgo.Recomendacion) |"
}

$lineasInforme += @(
    ""
    "## 4. Recomendaciones"
    ""
    "- Validar los accesos no esperados con los responsables de cada recurso."
    "- Revisar las asignaciones de las cuentas inactivas y confirmar si procede retirar sus permisos."
    "- Mantener actualizada la matriz de accesos esperados."
    "- Registrar la aprobación y las acciones correctivas en un proceso de revisión de accesos."
    ""
    "## 5. Alcance y limitaciones"
    ""
    "Esta auditoría utiliza datos CSV ficticios y una matriz de accesos esperados definida para el laboratorio."
    "Un acceso no esperado es un hallazgo que requiere validación; no demuestra por sí solo que exista una infracción."
    "El script no modifica cuentas ni permisos."
    ""
)

$lineasInforme |
    Set-Content -LiteralPath $rutaInformeMarkdown -Encoding UTF8

Write-Host "Informe Markdown generado: $rutaInformeMarkdown"
