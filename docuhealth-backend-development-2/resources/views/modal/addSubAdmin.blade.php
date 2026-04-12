<!--Add Banner Modal -->
<div class="modal fade text-left" id="add_sub_admin_modal" tabindex="-1" role="dialog"
  aria-hidden="true">
  <div class="modal-dialog modal-dialog-top modal-dialog-scrollable modal-lg">
    <div class="modal-content">
      <div class="modal-header">
        <h4 class="modal-title">Add Sub Admin</h4>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <i class="bx bx-x"></i>
        </button>
      </div>
      <div class="modal-body">
        <form class="form form-vertical" id="add_sub_admin_data" enctype="multipart/form-data">
          @csrf
          <div class="form-body">
            <div class="row">
              <!-- <div class="col-12">
                <div class="form-group">
                  <label for="profile_pic">Profile Picture</label>
                  <div class="position-relative has-icon-left">
                    <input type="file" class="form-control-file" id="profile_pic" name="profile_pic">
                  </div>
                </div>
              </div> -->
              <div class="col-12">
                <div class="form-group">
                  <label for="name">Name</label>
                  <div class="position-relative has-icon-left">
                    <input type="text" id="name" class="form-control" name="name" placeholder="Enter Name">
                    <div class="form-control-position">
                      <i class='bx bxs-rename'></i>
                    </div>
                  </div>
                </div>
              </div>
              <div class="col-12">
                <div class="form-group">
                  <label for="add_game_code">Phone</label>
                  <div class="position-relative has-icon-left">
                    <input type="number" id="phone" class="form-control" name="phone" placeholder="Enter Phone Number">
                    <div class="form-control-position">
                      <i class='bx bxs-phone'></i>
                    </div>
                  </div>
                </div>
              </div>
              <div class="col-12">
                <div class="form-group">
                  <label for="add_game_fraction">Email</label>
                  <div class="position-relative has-icon-left">
                    <input type="email" id="email" class="form-control" name="email" placeholder="Enter Email">
                    <div class="form-control-position">
                      <i class='bx bx-mail-send'></i>
                    </div>
                  </div>
                </div>
              </div>

              <div class="col-12"><div class="form-group">
                <label class="text-bold-600">Specializations</label>
                  <select name="specializations[]" id="specializations" multiple>
                    <option value=""></option>
                  </select>
                </div>
              </div>

              <div class="col-6">
                <div class="form-group">
                  <label for="add_game_type_video_link">Password</label>
                  <div class="position-relative has-icon-left">
                    <input type="password" id="password" class="form-control" name="password" placeholder="Enter Password">
                    <div class="form-control-position">
                      <i class='bx bxs-lock-alt'></i>
                    </div>
                  </div>
                </div>
              </div>
              <div class="col-6">
                <div class="form-group">
                  <label for="confirm_password">Confirm Password</label>
                  <div class="position-relative has-icon-left">
                    <input type="password" id="confirm_password" class="form-control" name="confirm_password" placeholder="Enter Password">
                    <div class="form-control-position">
                      <i class='bx bxs-lock-alt'></i>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </form>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-light-secondary" data-dismiss="modal">
          <i class="bx bx-x d-block d-sm-none"></i>
          <span class="d-none d-sm-block">Close</span>
        </button>
        <button type="button" class="btn btn-primary ml-1 add-sub-admin-btn">
          <i class="bx bx-check d-block d-sm-none"></i>
         Add
        </button>
      </div>
    </div>
  </div>
</div>
<script>
$(document).on('click', '.add-sub-admin-btn', function() {

          //get and set the from data.
          var myform = document.getElementById("add_sub_admin_data");
          var formData = new FormData(myform);
          formData.append('_token', '{{ csrf_token() }}');

          $('#add_sub_admin_data :file').each(function() {
              var thisName = $(this).attr("name");
              var image = $('input[name='+thisName+']');
              if (typeof image[0] !== 'undefined') {
                var FileToUpload = image[0].files[0];
                formData.append(thisName, FileToUpload);
              }
              formData.append(thisName, null);
          });
          
          $(this).html('Saving...').attr('disabled', true);
          $.ajax({
              type: "post",
              data: formData,
              cache:false,
              contentType: false,
              processData: false,
              url: "{{url('/')}}{{$auth_path}}/sub-admin",
              success: function(result) {
                  $('.add-sub-admin-btn').html('Add').attr('disabled', false);
                  if (result.success == false) {
                      Toast.fire({
                        icon: 'error',
                        title: result.msg
                      })
                  }else{
                      Toast.fire({
                        icon: 'success',
                        title: result.msg
                      })
                      $('#add_sub_admin_modal').modal('toggle');
                      $('#SubAdminTable').DataTable().ajax.reload();
                  }
              }
          });
    });

    const get_specializations = (id = 0) => {

        $.ajax({
              type: "get",
              url: "{{url('/')}}/get-specializations",
              success: function(result) {
                let data = result.data;
                let specializationOptions = '';

                data.forEach((value, index) => {
                  specializationOptions = `<option value="${value.id}">${value.name}</option>`;
                });

                $('#specializations').html(specializationOptions).select2({
                  width: '100%',
                  placeholder: '--select specializations --'
                });
              }
          });
    }

    get_specializations();
</script>