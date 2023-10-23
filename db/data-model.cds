namespace incidents.mgt;

using
{
    cuid,
    managed
}
from '@sap/cds/common';

entity Incidents : cuid, managed
{
    title : String(100);
    conversations : Composition of many Conversations on conversations.incidents = $self;
}

entity Conversations : cuid, managed
{
    incidents : Association to one Incidents;
    timestamp : DateTime;
    author : String(100);
    message : String;
}
