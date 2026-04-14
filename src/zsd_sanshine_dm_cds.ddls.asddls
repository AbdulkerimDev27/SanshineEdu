@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Data Model CDS'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZSD_SANSHINE_DM_CDS as select from ZCDS_PRODUCT_SANSHINE
{
    key SalesDocument,
    key SalesDocumentItem,
         Customer,
         CustomerName,
         SalesOffice,
         SalesGroup,
         DistributionChannel,
         CreatedBy,
         CreatedDate,
         Product,
         ProductDescription,
         RejectionReason,
         SalesUnit,
         ConfirmedDate,
         Plant,
         StorageLocation,
         Batch,
         RestrictionIndicator,
         BlockedIndicator,
         ReasonDescription,
         Description1,
         Description2
}
