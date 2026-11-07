
# Aplicacion de Esc. San Jose
### Informe Tcenico
Nuestra aplicación es básicamente un apoyo a la inclusión para el acompañamiento docente en ayuda de los alumnos que tengas una forma diferente de aprendizaje, a través de la interfaz que hemos diseñado de la cual es amigable y accesible tanto para las docentes como para los alumnos. 
### ***1. Objetivos Estratégicos de la Plataforma***<br>
•	Personalización del aprendizaje: Permitir a los docentes o tutores diseñar y asignar actividades específicas adaptadas al nivel de cada alumno en materias madres (Lengua y Matemáticas).<br>
•	Fomento de la autonomía infantil: Ofrecer a los niños un entorno intuitivo, visual y lúdico para estudiar, practicar y organizarse de manera independiente.<br>
•	Apoyo al bienestar socioemocional: Integrar herramientas de autorregulación, relajación y rutinas que complementen el aprendizaje académico con el bienestar emocional.<br>
•	Seguridad y control parental/docente: Proteger las configuraciones de gestión y edición mediante un sistema de acceso restringido para adultos.<br><br>
### ***2. Estructura de Módulos y Partes de la Aplicación***<br>
Pantalla de Bienvenida y Selección de Rol
Filtro inicial de acceso a la plataforma con dos flujos claros segregados por colores y propósitos: ***Maestra Principal*** (Gestión) y ***Alumno*** (Entorno de aprendizaje).<br>
***Módulo de Seguridad (PIN de Acceso)***<br>
Teclado numérico visual integrado para el ingreso de un código PIN de 4 dígitos que restringe el acceso al panel docente.
Panel de la Maestra Principal
Entorno administrativo con pestañas dinámicas de gestión<br>

***PANEL DE MAESTRA :***
- Asignar: Creación parametrizada de actividades
    - lengua:letras fañltantes,unir con flechas, escribir pictogramas
    - matematica: ecuacion, contar con pictogramas, orden cronologico, tablas de multiplicar

- Perfil y PIN: Modificación de metadatos del docente y claves de seguridad.
- Pestañas Adicionales: Creadas, Corregir y Alumnos para el seguimiento continuo.<br><br>
***PANEL DE ALUMNO***<BR>
Interfaz de login simplificada para el estudiante basada en avatares visuales y tipografía clara para facilitar la identificación del perfil propio.
Panel / Interfaz del Alumno
Menú principal del estudiante segmentado en tres bloques:
- Bloque Pedagógico: Lengua, Matemáticas y Tablas de Multiplicar.
- Bloque de Bienestar: Pausa de Respiración y menú de contención de Calma.
- Soporte diario: Módulos de Rutinas, Comunicación adaptada y soporte de texto a voz (TTS).
3. Matriz de Componentes por Rol<br>
### Componentes del Sistema (Arquitectura de Roles)

| Módulo | Rol de Acceso | Impacto Operativo |
| :--- | :--- | :--- |
| **Panel Docente** | Maestra Principal | Creación de tareas personalizadas y gestión de seguridad. |
| **Control de Acceso** | Sistema (PIN) | Bloqueo de seguridad para evitar ediciones accidentales del niño. |
| **Panel Infantil** | Alumno | Ejecución de actividades de Lengua, Matemáticas y autorregulación emocional. |

