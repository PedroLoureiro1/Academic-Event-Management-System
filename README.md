Project Description:
The task is to design and implement a Prolog-based Academic Event Management System. This system will be used to manage academic events such as lectures, workshops, and seminars, taking into account various parameters like rooms, schedules, courses, and disciplines. The system will perform various operations to identify problematic events, organize and filter events based on different criteria, and calculate resource usage (e.g., room occupation).

Key Features:
Event Data Quality:

Identifying events without rooms: Implement predicates to identify events that are missing room assignments.

eventosSemSalas/1: Lists events with no assigned rooms.

eventosSemSalasDiaSemana/2: Lists events without rooms on a specific weekday.

eventosSemSalasPeriodo/2: Lists events without rooms in a specific period (e.g., p1, p2).

Simple Queries:

Event organization by periods:

organizaEventos/3: Organizes a list of events by their associated periods.

Event duration filter:

eventosMenoresQue/2: Filters events by their duration, listing those with a duration equal to or less than a specified value.

eventosMenoresQueBool/2: Checks if a specific event has a duration less than or equal to a given value.

Course disciplines search:

procuraDisciplinas/2: Lists the courses’ disciplines alphabetically.

Organizing disciplines by semester:

organizaDisciplinas/3: Organizes disciplines within two lists, separating them by semester.

Course hour calculation:

horasCurso/5: Calculates the total number of hours assigned to events for a particular course during a specific year and period.

Evolution of course hours:

evolucaoHorasCurso/2: Tracks the evolution of course hours over the years and periods.

Room Occupation Calculation:

Slot overlap calculation:

ocupaSlot/5: Calculates the overlapping hours between a given time slot and an event’s duration.

Room occupation by type:

numHorasOcupadas/6: Calculates the number of hours rooms of a specific type are occupied within a given time slot and period.

Max room occupation:

ocupacaoMax/5: Calculates the maximum possible room occupation within a given time slot.

Percentage of room occupation:

percentagem/3: Calculates the percentage of room occupation based on the total occupied hours and maximum possible hours.

Tasks and Predicates to Implement:
Quality of Event Data:

eventosSemSalas/1

eventosSemSalasDiaSemana/2

eventosSemSalasPeriodo/2

Simple Searches and Organizing Events:

organizaEventos/3

eventosMenoresQue/2

eventosMenoresQueBool/2

procuraDisciplinas/2

organizaDisciplinas/3

horasCurso/5

evolucaoHorasCurso/2

Room Occupation Calculations:

ocupaSlot/5

numHorasOcupadas/6

ocupacaoMax/5

percentagem/3

This system will allow for efficient management of academic events, improve scheduling, and help identify critical issues with resource usage such as room occupancy.