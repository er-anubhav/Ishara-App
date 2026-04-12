<?php
$auth = auth()->user()->role;
$auth_path = auth()->user()->role == 'admin' ? 'admin' : '' ;
?>
<!DOCTYPE html>

<html class="loading" lang="en" data-textdirection="ltr">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0">
    <title>Sub Admin - Docuhelath</title>
@include('admin.layout.header')
    <!-- BEGIN: Content-->
    <div class="app-content content">
      <div class="content-overlay"></div>
      <div class="content-wrapper">
        <div class="content-header row">
        </div>
        <div class="content-body">
            <section class="users-list-wrapper">
   <div class="row mt-2">    
    <div class="col-md-12 col-sm-12 dashboard-referral-impression">
      <div class="row">
         <div class="col-md-12 col-12 dashboard-users-success">
          <div class="card">
            <div class="card-body py-1">
              <div class="row">
                <div class="col-12">
                  <div class="table-responsive">
                    <table id="SubAdminTable" class="table " style="width: 100%;">
                      <thead>
                        <tr>
                          <th>Name</th>
                          <th>Contact</th>
                          <th>Specializations</th>
                          <th>Registered On</th>
                          <th>Status</th>
                          <th>Action</th>
                        </tr>
                      </thead>
                      <tbody>
                    
                      </tbody>
                    </table>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

  </div>
</section>
<!-- users list ends -->

</div></div>
<div class="buy-now" style="right: 60px;"><button type="button" class="btn btn-danger" data-toggle="modal" data-target="#add_sub_admin_modal">+</button></div>
</div>
<div class="sidenav-overlay"></div>
<div class="drag-target"></div>
 <!-- Earning Swiper Starts -->

@include('admin.layout.footer')
@include('modal.addSubAdmin')
@include('modal.updateSubAdmin') 
<script>
$(document).ready( function () {

      var SubAdminTable = $('#SubAdminTable');

      SubAdminTable.DataTable({
          responsive: true,
          serverSide: true,
          processing: true,
          ordering: false,
          ajax: "{{url('/')}}/{{$auth_path}}/sub-admin/data",
          "aoColumns": [
              {
                  mData: 'name'
              },
              {
                  mData: 'contact'
              },
              {
                  mData: 'specializations'
              },
              {
                  mData: 'created_at'
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
        var action = $(this).attr('name');

        if (action == 'delete') {

          Swal.fire({
            title: 'You wont be able to retrive this!',
            showDenyButton: true,
            confirmButtonText: `Ok, Delete it.`,
            denyButtonText: `No, Cancel it.`,
          }).then((result) => {
            if (result.isConfirmed) {
              status_change(id, action);
            } 
          })
        }else{
          status_change(id, action);
        }
    });

    const status_change = (id = 0, action = 'enable') => {
      $.ajax({
              type: "post",
              url: "{{url('/')}}/{{$auth_path}}/categories/status",
              data: { 'id' :id , 'status': action, '_token' : '{{ csrf_token() }}' },
              success: function(result) {
                  if (result.error == true) {
                      Toast.fire({
                        icon: 'error',
                        title: result.message
                      })
                  }else{
                      Toast.fire({
                        icon: 'success',
                        title: result.message
                      })
                  }
                  SubAdminTable.DataTable().ajax.reload();
              }
          });
    }
});
</script>

</body>
</html>