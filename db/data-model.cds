namespace incidents.mgt;

using
{
    cuid,
    managed,
    sap.common.CodeList
}
from '@sap/cds/common';

/**
 * Incidents created by Customers.
 */
entity Incidents : cuid, managed {
  title        : String                  @title : 'Title';
  urgency      : Association to Urgency  @title: 'Urgency';
  status       : Association to Status   @title: 'Status';
  conversations : Composition of many Conversations  on conversations.incidents = $self;
}

entity Status : CodeList {
  key code        : String enum {
        new        = 'N';
        assigned   = 'A';
        in_process = 'I';
        on_hold    = 'H';
        resolved   = 'R';
        closed     = 'C';
      };
      criticality : Integer;
}

entity Urgency : CodeList {
  key code : String enum {
        high   = 'H';
        medium = 'M';
        low    = 'L';
      };
      criticality : Integer;
}

entity Conversations : cuid, managed {
  incidents : Association to Incidents;
  timestamp : DateTime @cds.on.insert: $now   @title: 'Time';
  author    : String   @cds.on.insert: $user  @title: 'Author' ;
  message   : String                          @title: 'Message';
}
