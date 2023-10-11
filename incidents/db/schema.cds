using { cuid, managed, sap.common.CodeList } from '@sap/cds/common';

namespace acme.incmgt;

/**
 * Incidents created by Customers.
 */
entity Incidents : cuid, managed {
  title        : String                  @title : 'Title';
  urgency      : Association to Urgency  @title: 'Urgency';
  status       : Association to Status   @title: 'Status';
  conversations : Composition of many Conversations;
}

entity Status : CodeList {
  key code        : String enum {
        new        = 'N'    @title: 'New'         @description: 'An incident that has been logged but not yet worked on.';
        assigned   = 'A'    @title: 'In Process'  @description: 'Case is being actively worked on';
        in_process = 'I'    @title: 'In Process'  @description: 'Case is being actively worked on';
        on_hold    = 'H'    @title: 'On Hold'     @description: 'Incident has been put on hold';
        resolved   = 'R'    @title: 'Resolved'    @description: 'Resolution has been found';
        closed     = 'C'    @title: 'Closed'      @description: 'Incident was acknowleged closed by end user';
      };
      criticality : Integer;
}

entity Urgency : CodeList {
  key code : String enum {
        high   = 'H' @title: 'High' ;
        medium = 'M' @title: 'Medium';
        low    = 'L' @title: 'Low';
      };
}

entity Conversations : cuid, managed {
  incidents : Association to Incidents;
  timestamp : DateTime @cds.on.insert: $now   @title: 'Time';
  author    : String   @cds.on.insert: $user  @title: 'Author' ;
  message   : String                          @title: 'Message';
}

type EMailAddress : String;
type PhoneNumber : String;
type City : String;
