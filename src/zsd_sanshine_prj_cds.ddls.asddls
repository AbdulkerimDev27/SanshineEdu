@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection CDS'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZSD_SANSHINE_PRJ_CDS as projection on ZSD_SANSHINE_DM_CDS
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
