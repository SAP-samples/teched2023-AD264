using { incidents.mgt } from '../db/data-model';

service ProcessorService {

    @odata.draft.enabled
    entity Incidents as projection on mgt.Incidents;
  
}

