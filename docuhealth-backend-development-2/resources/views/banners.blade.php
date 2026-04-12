<?php
$auth = auth()->user()->role;
$auth_path = auth()->user()->role == 'Admin' ? 'admin' : '' ;
?>
<!DOCTYPE html>

<html class="loading" lang="en" data-textdirection="ltr">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0">
  <meta name="author" content="PIXINVENT">
    <title>Banners - Docuhealth</title>
@include('layouts.header')

    <!-- BEGIN: Content-->
    <div class="app-content content">
      <div class="content-overlay"></div>
      <div class="content-wrapper">
        <div class="content-header row">
        </div>
        <div class="content-body">
<section class="users-list-wrapper">
    <div class="users-list-table" style="margin-top: 20px;">
        <div class="card">
            <div class="card-body">
                <!-- datatable start -->
                <div class="table-responsive">
                    <table id="BannerTable" class="table " style="width: 100%;">
                        <thead>
                            <tr>
                                <th>Image</th>
                                <th>Type</th>
                                <th>Position</th>
                                <th>Status</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                      
                        </tbody>
                    </table>
                </div>
                <!-- datatable ends -->
            </div>
        </div>
    </div>
</section>
<!-- users list ends -->

<div class="buy-now" style="right: 60px;"><button type="button" class="btn btn-danger" data-toggle="modal" data-target="#add_new_banner"> +</button></div>

</div>
    <div class="sidenav-overlay"></div>
    <div class="drag-target"></div>
     <!-- Earning Swiper Starts -->
  @include('layouts.footer')
  @include('modal.addBanner')
  @include('modal.updateBanner')
  <script>
  $(document).ready( function () {

      var BannerTable = $('#BannerTable');

       BannerTable.DataTable({

          // dom: '<"html5buttons"B>lTfgitp',
          buttons: [
              {extend: 'copy'},
              {extend: 'csv'},
              {extend: 'excel', title: 'BannerFile'},
              {extend: 'pdf', title: 'BannerFile'},

              {extend: 'print',
               customize: function (win){
                      $(win.document.body).addClass('white-bg');
                      $(win.document.body).css('font-size', '10px');

                      $(win.document.body).find('table')
                              .addClass('compact')
                              .css('font-size', 'inherit');
              }
              }
          ],
          responsive: true,
          serverSide: true,
          processing: true,
          ordering: false,
          ajax: "{{url('admin/banners/data')}}",
          "aoColumns": [
          //  {
          //         render: function(data, type, row, meta) {
          //           return meta.row + meta.settings._iDisplayStart + 1;
          //         }
          //  },
              {
                  mData: 'image'
              },
              {
                  mData: 'type'
              },
              {
                  mData: 'position'
              },
              {
                  mData: 'status'
              },
              {
                  mData: 'action'
              },

          ],
          "columnDefs": [{
              targets: -1,
              className: 'text-right'
          }],
    });

    $(document).on('click', '.status-btn', function(e) {
        e.stopPropagation();
        var id = $(this).attr('data-value');
        var status = $(this).attr('name');
        $(this).attr('disabled', 'disabled');
        Swal.fire({
            title: 'Are you really want to '+status+' this user!',
            showDenyButton: true,
            confirmButtonText: `Yes, `+status+` it.`,
            denyButtonText: `No, Cancel it.`,
          }).then((result) => {
            if (result.isConfirmed) {
              statusChange(id, status);
            }else{ $('.status-btn').removeAttr('disabled'); }
          })
    });

    function statusChange(id, status){
      $.ajax({
              type: "post",
              url: "{{url('/')}}/{{$auth_path}}/banners/status",
              data: { 'id' :id , 'status' : status, '_token' : '{{ csrf_token() }}' },
              success: function(result) {
                $('.status-btn').removeAttr('disabled');
                    if (result.error == true) {
                      Toast.fire({ icon: 'error', title: result.message });
                    }else{
                      Toast.fire({ icon: 'success', title: result.message });
                    }
                    BannerTable.DataTable().ajax.reload();
              }
          });
    }

});
</script>

</body>
<!-- END: Body-->

</html>