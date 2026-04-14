CLASS lhc_ZSD_SANSHINE_DM_CDS DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zsd_sanshine_dm_cds RESULT result.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zsd_sanshine_dm_cds RESULT result.
    METHODS testfonksiyon FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zsd_sanshine_dm_cds~testfonksiyon.
    METHODS validateProduct FOR VALIDATE ON SAVE
      IMPORTING keys FOR zsd_sanshine_dm_cds~validateProduct.
    METHODS setApproved FOR MODIFY
      IMPORTING keys FOR ACTION zsd_sanshine_dm_cds~setApproved RESULT result.
    METHODS sendMail FOR MODIFY
      IMPORTING keys FOR ACTION zsd_sanshine_dm_cds~sendMail RESULT result.
    METHODS callBAPI FOR MODIFY
      IMPORTING keys FOR ACTION zsd_sanshine_dm_cds~callBAPI RESULT result.
    METHODS TestExecute FOR MODIFY
      IMPORTING keys FOR ACTION zsd_sanshine_dm_cds~TestExecute RESULT result.
    METHODS GetData FOR MODIFY
      IMPORTING keys FOR ACTION zsd_sanshine_dm_cds~GetData RESULT result.

ENDCLASS.

CLASS lhc_ZSD_SANSHINE_DM_CDS IMPLEMENTATION.

  METHOD get_instance_authorizations.
    " Tüm kullanıcılara tüm yetkileri ver (Geçici olarak)
    APPEND VALUE #( %tky = keys[ 1 ]-%tky
                    %update = if_abap_behv=>auth-allowed
                    %delete      = if_abap_behv=>auth-allowed ) TO result.
  ENDMETHOD.

  METHOD get_global_authorizations.

  ENDMETHOD.

  METHOD TestFonksiyon.
    "Bir veri girişini belirli bir duruma göre manipüle etme.
    READ ENTITIES OF zsd_sanshine_dm_cds IN LOCAL MODE
      ENTITY zsd_sanshine_dm_cds
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_products).

    READ TABLE lt_products INTO DATA(ls_my_product) INDEX 1.
    IF ls_my_product-Product IS INITIAL.
      MODIFY ENTITIES OF zsd_sanshine_dm_cds IN LOCAL MODE
             ENTITY zsd_sanshine_dm_cds
             UPDATE FIELDS ( Product )
                WITH VALUE #( FOR key IN keys (
                        %tky         = key-%tky
                        Product = 'BOŞ'
                   ) )
         REPORTED DATA(reported_records_0)
         FAILED   DATA(failed_records_0).
    ENDIF.

    "Bir veri girişini doğrudan manipüle etme.
    MODIFY ENTITIES OF zsd_sanshine_dm_cds IN LOCAL MODE
          ENTITY zsd_sanshine_dm_cds
            UPDATE FIELDS ( CreatedBy CreatedDate )
            WITH VALUE #( FOR key IN keys (
                               %tky         = key-%tky
                               CreatedBy = 'ABDULKERIM'
                               CreatedDate = cl_abap_context_info=>get_system_date( )
                          ) )
        REPORTED DATA(reported_records)
        FAILED   DATA(failed_records).
  ENDMETHOD.


  METHOD validateProduct.
    READ ENTITIES OF zsd_sanshine_dm_cds IN LOCAL MODE
      ENTITY zsd_sanshine_dm_cds
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_products).


    LOOP AT lt_products INTO DATA(ls_my_product).

      IF ls_my_product-Product = 'EKSI'.

        " Kaydı durdur
        APPEND VALUE #( %tky = ls_my_product-%tky ) TO failed-zsd_sanshine_dm_cds.

        " Mesajı ekle
        APPEND VALUE #( %tky = ls_my_product-%tky
                        %msg  = new_message_with_text(
                                  severity = if_abap_behv_message=>severity-error
                                  text     = 'EKSI ürünü için kayıt girişi yasaklanmıştır!' )
                        %element-product = if_abap_behv=>mk-on
                      ) TO reported-zsd_sanshine_dm_cds.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD setApproved.
    " 1. Önce Mevcut Durumu Oku
    READ ENTITIES OF zsd_sanshine_dm_cds IN LOCAL MODE
      ENTITY zsd_sanshine_dm_cds
        FIELDS ( Description1 ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_current_data).

    READ TABLE lt_current_data INTO DATA(ls_Check_data) INDEX 1.
    IF ls_check_data-Description1 EQ 'ONAYLANDI'.
      APPEND VALUE #(
        %tky = ls_check_data-%tky
        %msg = new_message_with_text(
                 severity = if_abap_behv_message=>severity-error
                 text     = 'Sipariş Önceden Zaten Onaylandı'
               )
        %element-description1 = if_abap_behv=>mk-on
    ) TO reported-zsd_sanshine_dm_cds.

    ELSE.
      " IN LOCAL MODE: Yetki kontrollerini atlayarak doğrudan buffer üzerinde işlem yapar.
      MODIFY ENTITIES OF zsd_sanshine_dm_cds IN LOCAL MODE
        ENTITY zsd_sanshine_dm_cds
          UPDATE FIELDS ( Description1 )
          WITH VALUE #( FOR key IN keys (
                             %tky         = key-%tky
                             Description1 = 'ONAYLANDI'
                        ) )
      REPORTED DATA(lt_reported)
      FAILED DATA(lt_failed).

      " 2. Hata Kontrolü: Eğer işlem başarısız olursa sistem FAILED tablosunu döner
      failed-zsd_sanshine_dm_cds = CORRESPONDING #( lt_failed-zsd_sanshine_dm_cds ).
      reported-zsd_sanshine_dm_cds = CORRESPONDING #( lt_reported-zsd_sanshine_dm_cds ).
      "Ekrana Başarı Mesajı Bas
      IF lt_failed IS INITIAL.
        READ TABLE keys ASSIGNING FIELD-SYMBOL(<ls_key>) INDEX 1.
        APPEND VALUE #(
            %tky = <ls_key>-%tky
            %msg = new_message_with_text(
                     severity = if_abap_behv_message=>severity-success " Yeşil mesaj
                     text     = 'Sipariş Onaylandı'
                   )
            %element-description1 = if_abap_behv=>mk-on " İlgili alanı işaretle
        ) TO reported-zsd_sanshine_dm_cds.
      ENDIF.
    ENDIF.

    " İşlem bittikten sonra UI'daki satırın güncellenmesi için veriyi tekrar okumamız gerekir.
    READ ENTITIES OF zsd_sanshine_dm_cds IN LOCAL MODE
      ENTITY zsd_sanshine_dm_cds
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_products).

    result = VALUE #( FOR product IN lt_products (
                         %tky   = product-%tky
                         %param = product
                    ) ).



  ENDMETHOD.

  METHOD sendMail.
*    TRY.
*        " Mail nesnesini oluştur
*        DATA(lo_mail) = cl_bcs_mail_message=>create_instance( ).
*
*        " Gönderici ve Alıcı Bilgileri
*        lo_mail->set_sender( 'info@sanko.com' ).
*        lo_mail->add_recipient( 'abdulkerim.yenidogan@sanshine.com.tr' ). " Buraya dinamik mail adresi de gelebilir
*
*        " Konu ve İçerik
*        lo_mail->set_subject( | Sipariş Onaylandı | ).
*
*        DATA(lv_body) = |Sayın Kullanıcı,\n\n| &&
*                        |sipariş başarıyla onaylanmıştır.\n| &&
*                        |İşlem Tarihi: { cl_abap_context_info=>get_system_date( ) }\n\n| &&
*                        |Bu otomatik bir mesajdır.|.
*
*        lo_mail->set_main( iv_contents = lv_body
*                                   iv_content_type = 'text/plain' ).
*
*        " Maili Gönder
*        lo_mail->send( ).
*
*      CATCH cx_bcs_mail INTO DATA(lx_mail).
*        READ ENTITIES OF zsd_sanshine_dm_cds IN LOCAL MODE
*             ENTITY zsd_sanshine_dm_cds
*               ALL FIELDS WITH CORRESPONDING #( keys )
*             RESULT DATA(lt_products).
*
*             READ TABLE lt_products INTO DATA(ls_product) INDEX 1.
*
*        APPEND VALUE #( %tky = ls_product-%tky
*                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
*                                                      text     = 'Mail gönderilemedi: ' && lx_mail->get_text( ) )
*                      ) TO reported-zsd_sanshine_dm_cds.
*    ENDTRY.


    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key_err>).
      APPEND VALUE #( %tky = <ls_key_err>-%tky
                      %msg = new_message_with_text(
                               severity = if_abap_behv_message=>severity-error
                               text     = 'Mail gönderilemedi'
                             )
                    ) TO reported-zsd_sanshine_dm_cds.
    ENDLOOP.

  ENDMETHOD.

  METHOD callBAPI.

    READ ENTITIES OF zsd_sanshine_dm_cds IN LOCAL MODE
           ENTITY zsd_sanshine_dm_cds
           ALL FIELDS WITH CORRESPONDING #( keys )
           RESULT DATA(lt_data).


    READ TABLE lt_data ASSIGNING FIELD-SYMBOL(<ls_key>) INDEX 1.

    "Update Methodu
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*    MODIFY ENTITIES of I_ProductTP_2
*     ENTITY Product
*     UPDATE FIELDS ( ProductGroup ManufacturerNumber ProductManufacturerNumber
*     ManufacturerPartProfile OwnInventoryManagedProduct )
*     WITH VALUE #( ( %key-Product = <LS_KEY>-product
*     ProductGroup = 'PRD_GRP'
*     ManufacturerNumber = '1234'
*     ProductManufacturerNumber = '123'
*     ManufacturerPartProfile = '0001'
*     OwnInventoryManagedProduct = '1111' ) )
*
*     FAILED DATA(failed)
*     REPORTED DATA(reported).
*
*IF FAILED IS INTIAL.
*    COMMIT ENTITIES
*        RESPONSE OF I_ProductTP_2
*            FAILED DATA(failed_commit)
*            REPORTED DATA(reported_commit).
*ELSE.
*   ROLLBACK ENTITIES.
*ENDIF.
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    "Create Methodu
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*DATA lt_create_prod TYPE TABLE FOR CREATE I_ProductTP_2.
*
*lt_create_prod = VALUE #( (
*    %cid = 'MY_FRONTEND_ID_1'            " Geçici ID (Çok Kritik!)
*    Product            = 'ZNEW_MAT_001'  " Yeni Malzeme No
*    ProductType        = 'MARA'          " Zorunlu alan örn: Malzeme Türü
*    BaseUnit           = 'PC'            " Zorunlu alan örn: Temel Ölçü Birimi
*    ProductGroup       = 'PRD_GRP'
*    %control-ProductType = if_abap_behv=>mk-on
*    %control-BaseUnit    = if_abap_behv=>mk-on
*) ).
*
*MODIFY ENTITIES OF I_ProductTP_2
*  ENTITY Product
*    CREATE FROM lt_create_prod
*  MAPPED DATA(lt_mapped)    " Yeni yaratılan ID'leri burada tutar
*  FAILED DATA(lt_failed)    " Hata varsa buraya düşer
*  REPORTED DATA(lt_reported). " Hata mesajlarını getirir
*
*IF lt_failed IS INITIAL.
*  COMMIT ENTITIES.
*ELSE.
*   ROLLBACK ENTITIES.
*ENDIF.
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    "Delete Methodu
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*DATA lt_delete_prod TYPE TABLE FOR DELETE I_ProductTP_2.
*
*lt_delete_prod = VALUE #( (
*    Product = 'ZNEW_MAT_001' " Silmek istediğin Malzeme No
*) ).
*
*
*MODIFY ENTITIES OF I_ProductTP_2
*  ENTITY Product
*    DELETE FROM lt_delete_prod
*  FAILED DATA(lt_failed_del)
*  REPORTED DATA(lt_reported_del).
*
*IF lt_failed_del IS INITIAL.
*    COMMIT ENTITIES.
*    " Başarılı!
*ELSE.
*    ROLLBACK ENTITIES.
*    " Hata mesajlarını ls_reported_del içinden okuyabilirsin
*ENDIF.
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    "Execute Methodu
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " (Varsa Action parametrelerini de burada doldururuz)
*MODIFY ENTITIES OF I_ProductTP_2
*  ENTITY Product
*    EXECUTE setApproved          " Tetiklemek istediğiniz Action adı
*      FROM VALUE #( (
*          Product = 'SANS_PROD_001' " Hangi malzeme?
*"          %param  = VALUE #( ProductText )  " Eğer Action parametre alıyorsa burası doldurulur
*      ) )
*  MAPPED DATA(ls_mapped)
*  FAILED DATA(ls_failed)
*  REPORTED DATA(ls_reported)
*  RESULT DATA(lt_action_result).    " Action bir veri dönüyorsa buraya düşer
*
*IF ls_failed IS INITIAL.
*  COMMIT ENTITIES.
*ELSE.
*  ROLLBACK ENTITIES.
*ENDIF.
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    "Yetki Kontrolleri
    "Aşağıda Product BO standart bir obje olduğu için rol yönetim ekranından rol tanımlaması yapılabilir.
    "kendi BO'larımızda get auth ve get inst içinde rol objeleriyle yetkilendirme yapabiliriz.
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*READ ENTITIES OF I_ProductTP_2
*  ENTITY Product
*    GET PERMISSIONS ONLY
*    FROM VALUE #( ( Product = 'MALZEME_1' ) )
*    RESULT DATA(lt_perm).
*
*DATA(ls_perm) = lt_perm[ 1 ].
*
*IF ls_perm-%update = if_abap_behv=>auth-allowed.
*
*    MODIFY ENTITIES OF I_ProductTP_2
*      ENTITY Product
*        UPDATE FIELDS ( ProductGroup )
*        WITH VALUE #( ( Product = 'MALZEME_1' ProductGroup = 'GRP1' ) )
*      FAILED DATA(ls_failed).
*
*    IF ls_failed IS INITIAL.
*      COMMIT ENTITIES.
*    ENDIF.
*ELSE.
*    " Yetkiniz yok mesajı...
*ENDIF.
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    APPEND VALUE #( %tky = <ls_key>-%tky
                    %msg = new_message_with_text(
                             severity = if_abap_behv_message=>severity-success
                             text     = <ls_key>-Product && ' Malzemesi için malzeme çağrısı yapıldı!'
                           )
                  ) TO reported-zsd_sanshine_dm_cds.



    READ ENTITIES OF zsd_sanshine_dm_cds IN LOCAL MODE
         ENTITY zsd_sanshine_dm_cds
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(lt_products).

    result = VALUE #( FOR product IN lt_products (
                         %tky   = product-%tky
                         %param = product
                    ) ).
  ENDMETHOD.

  METHOD TestExecute.
    "Çalıştırmak istediğin kodları buraya yaz...
  ENDMETHOD.

  METHOD GetData.
  TRY.

        DATA(lo_destination) = cl_http_destination_provider=>create_by_url( 'https://jsonplaceholder.typicode.com/posts' ).

        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_destination ).

        DATA(lo_request) = lo_http_client->get_http_request( ).
        DATA(lo_response) = lo_http_client->execute( if_web_http_client=>get ).

        DATA(lv_response_json) = lo_response->get_text( ).

        DATA: lt_post_data TYPE TABLE OF zsd_api_abstarct_entity_cds.

        /ui2/cl_json=>deserialize(
          EXPORTING
           json = lv_response_json
           pretty_name      = /ui2/cl_json=>pretty_mode-camel_case
          CHANGING  data = lt_post_data ).


            READ TABLE keys ASSIGNING FIELD-SYMBOL(<ls_primary_key>) INDEX 1.

            IF sy-subrc = 0.
              LOOP AT lt_post_data ASSIGNING FIELD-SYMBOL(<ls_post>).
                APPEND VALUE #(
                    %tky   = <ls_primary_key>-%tky
                    %param = CORRESPONDING #( <ls_post> )
                ) TO result.
              ENDLOOP.
            ENDIF.


      CATCH cx_http_dest_provider_error cx_web_http_client_error INTO DATA(lx_error).
        " Hata kontrolleri
    ENDTRY.
  ENDMETHOD.

ENDCLASS.


CLASS lsc_ZSD_SANSHINE_DM_CDS DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS save_modified REDEFINITION.
ENDCLASS.

CLASS lsc_ZSD_SANSHINE_DM_CDS IMPLEMENTATION.
  METHOD save_modified.
    DATA ls_log TYPE zbtp_log.

    IF create-zsd_sanshine_dm_cds IS NOT INITIAL.
      READ TABLE create-zsd_sanshine_dm_cds INTO DATA(ls_create_data) INDEX 1.
      IF sy-subrc EQ 0.
        ls_log-client = sy-mandt.
        ls_log-vbeln = ls_create_data-SalesDocument.
        ls_log-posnr = ls_create_data-SalesDocumentItem.
        ls_log-name1 = ls_create_data-Product.
        ls_log-tarih = cl_abap_context_info=>get_system_date( ).
        ls_log-saat  = cl_abap_context_info=>get_system_time( ).
        ls_log-ernam = sy-uname.
        ls_log-statu = 'Oluşturuldu'.
        INSERT zbtp_log FROM @ls_log.
      ENDIF.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
