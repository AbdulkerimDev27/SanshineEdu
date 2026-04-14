@EndUserText.label: 'Product CDS'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define view entity ZCDS_PRODUCT_SANSHINE
  as select from zbtp_product
{
    key vbeln            as SalesDocument,
    key posnr            as SalesDocumentItem,
      kunnr            as Customer,
      name1            as CustomerName,
      vkbur            as SalesOffice,
      vkgrp            as SalesGroup,
      vtweg            as DistributionChannel,
      ernam            as CreatedBy,
      erdat            as CreatedDate,
      matnr_vbap       as Product,
      arktx            as ProductDescription,
      abgru            as RejectionReason,
      vrkme            as SalesUnit,
      zzconfirmed_date as ConfirmedDate,
      werks            as Plant,
      lgort            as StorageLocation,
      charg            as Batch,
      kains            as RestrictionIndicator,
      kaspe            as BlockedIndicator,
      redtanim         as ReasonDescription,
      bezei            as Description1,
      bezei2           as Description2
} 
