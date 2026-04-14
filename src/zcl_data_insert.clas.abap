CLASS zcl_data_insert DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_DATA_INSERT IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
      DATA lt_product TYPE STANDARD TABLE OF zbtp_product.
      DATA ls_product TYPE zbtp_product.

       CLEAR ls_product.
      ls_product-client       = sy-mandt.
      ls_product-vbeln        = |ABDULKERIM|.
      ls_product-posnr        = |{ sy-index }|.
      ls_product-kunnr        = |CUST{ sy-index }|.
      ls_product-name1        = |Customer { sy-index }|.
      ls_product-vkbur        = |VKB{ sy-index MOD 10 }|.
      ls_product-vkgrp        = |VK{ sy-index MOD 5 }|.
      ls_product-vtweg        = |01|.
      ls_product-ernam        = sy-uname.
      ls_product-erdat        = sy-datum.
      ls_product-matnr_vbap   = |MAT{ sy-index }|.
      ls_product-arktx        = |Product Desc { sy-index }|.
      ls_product-abgru        = |01|.
      ls_product-vrkme        = |PC|.
      ls_product-zzconfirmed_date = sy-datum.
      ls_product-werks        = |1000|.
      ls_product-lgort        = |0001|.
      ls_product-charg        = |BATCH{ sy-index }|.
      ls_product-kains        = |X|.
      ls_product-kaspe        = |Y|.
      ls_product-redtanim     = |Red Text { sy-index }|.
      ls_product-bezei        = |Desc1 { sy-index }|.
      ls_product-bezei2       = |Desc2 { sy-index }|.
      APPEND ls_product TO lt_product.

          INSERT zbtp_product FROM TABLE @lt_product.
          COMMIT WORK.
    out->write( |100 kayıt tabloya eklendi| ).
  ENDMETHOD.
ENDCLASS.
