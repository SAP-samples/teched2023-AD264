using { incidents.mgt } from '../db/data-model';

service ProcessorService {

    entity Incidents as projection on mgt.Incidents;

}

extend service ProcessorService with {
  entity Customers as projection on mgt.Customers;
}
