using { acme.incmgt } from '../db/schema';

service IncidentsService {
  entity Incidents      as projection on incmgt.Incidents;
}
