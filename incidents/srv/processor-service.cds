using { acme.incmgt } from '../db/schema';

service ProcessorService {

  entity Incidents as projection on incmgt.Incidents;

}


annotate ProcessorService.Incidents with @odata.draft.enabled;

annotate ProcessorService with @(requires: ['support']);
