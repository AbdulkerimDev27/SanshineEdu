@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Product Log CDS'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZSD_PRODUCT_LOG_CDS as select from zbtp_log
{
    key vbeln as Vbeln,
    key posnr as Posnr,
    name1 as Name1,
    tarih as Tarih,
    saat as Saat,
    ernam as Ernam,
    statu as Durum
}
