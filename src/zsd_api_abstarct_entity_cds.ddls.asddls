@EndUserText.label: 'API VERI DUZENI'
@Metadata.allowExtensions: true
define abstract entity ZSD_API_ABSTARCT_ENTITY_CDS
{
   @UI.lineItem: [{ position: 30, label: 'UserID' }]
  key userId : abap.int4;
  
  @UI.lineItem: [{ position: 30, label: 'ID' }]
  key id     : abap.int4;
  
  @UI.lineItem: [{ position: 30, label: 'TITLE' }]
  title  : abap.string;
  
  @UI.lineItem: [{ position: 30, label: 'BODY' }]
  body   : abap.string;
    
}
