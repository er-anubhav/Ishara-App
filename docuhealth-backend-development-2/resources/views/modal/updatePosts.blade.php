<!--Update Banner Modal -->
<div class="modal fade text-left" id="update_result_announcer" tabindex="-1" role="dialog"
  aria-hidden="true">
  <div class="modal-dialog modal-dialog-top modal-dialog-scrollable modal-lg">
    <div class="modal-content">
      <div class="modal-header">
        <h4 class="modal-title">Update Finance Manager</h4>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <i class="bx bx-x"></i>
        </button>
      </div>
      <div class="modal-body">
        <form class="form form-vertical" id="update_result_announcer_data" enctype="multipart/form-data">
          @csrf
          <input type="hidden" name="finance_manager_id" id="finance_manager_id">
          <div class="form-body">
            <div class="row">
              <div class="col-12">
                <div class="form-group">
                  <label for="update_result_announcer_profile_pic">Profile Picture</label>
                  <div class="position-relative has-icon-left">
                    <input type="file" class="form-control-file" id="update_result_announcer_profile_pic" name="profile_pic">
                  </div>
                </div>
              </div>
              <div class="col-12">
                <div class="form-group">
                  <label for="update_result_announcer_name">Name</label>
                  <div class="position-relative has-icon-left">
                    <input type="text" id="update_result_announcer_name" class="form-control" name="name" placeholder="Enter Name">
                    <div class="form-control-position">
                      <i class='bx bxs-rename'></i>
                    </div>
                  </div>
                </div>
              </div>
              <div class="col-12">
                <div class="form-group">
                  <label for="update_game_code">Phone</label>
                  <div class="position-relative has-icon-left">
                    <input type="number" id="update_result_announcer_phone" class="form-control" name="phone" placeholder="Enter Phone Number">
                    <div class="form-control-position">
                      <i class='bx bxs-label' ></i>
                    </div>
                  </div>
                </div>
              </div>
              <div class="col-12">
                <div class="form-group">
                  <label for="update_game_fraction">Email</label>
                  <div class="position-relative has-icon-left">
                    <input type="email" id="update_result_announcer_email" class="form-control" name="email" placeholder="Enter Email">
                    <div class="form-control-position">
                      <i class='bx bxs-label' ></i>
                    </div>
                  </div>
                </div>
              </div>
              <div class="col-6">
                <div class="form-group">
                  <label for="update_game_type_video_link">Password</label>
                  <div class="position-relative has-icon-left">
                    <input type="password" id="update_result_announcer_password" class="form-control" name="password" placeholder="Enter Password">
                    <div class="form-control-position">
                      <i class='bx bx-link' ></i>
                    </div>
                  </div>
                </div>
              </div>
              <div class="col-6">
                <div class="form-group">
                  <label for="update_result_announcer_confirm_password">Confirm Password</label>
                  <div class="position-relative has-icon-left">
                    <input type="password" id="update_result_announcer_confirm_password" class="form-control" name="confirm_password" placeholder="Enter Password">
                    <div class="form-control-position">
                      <i class='bx bx-link' ></i>
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
        <button type="button" class="btn btn-primary ml-1 update-result-announcer-btn">
          <i class="bx bx-check d-block d-sm-none"></i>
         Update
        </button>
      </div>
    </div>
  </div>
</div>
<script>

$(document).on('click', '.result-announcer-edit-btn', function() {

    var data = $(this).attr('data-value').split('|');
    $('#finance_manager_id').val(data[0]);
    $('#update_result_announcer_name').val(data[1]);
    $('#update_result_announcer_phone').val(data[2]);
    $('#update_result_announcer_email').val(data[3]);
    $('#update_result_announcer').modal('toggle');
});
$(document).on('click', '.update-result-announcer-btn', function() {

    //get and set the from data.
    var myform = document.getElementById("update_result_announcer_data");
    var formData = new FormData(myform);
    formData.append('_token', '{{ csrf_token() }}');

    $('#update_result_announcer_data :file').each(function() {
        var thisName = $(this).attr("name");
        var image = $('input[name='+thisName+']');
        if (typeof image[0] !== 'undefined') {
          var FileToUpload = image[0].files[0];
          formData.append(thisName, FileToUpload);
        }
        formData.append(thisName, null);
    });
    
    $(this).html('Updating...').attr('disabled', true);
    $.ajax({
        type: "post",
        data: formData,
        cache:false,
        contentType: false,
        processData: false,
        url: "{{url('result-announcer/update')}}",
        success: function(result) {
            $('.update-result-announcer-btn').html('Update').attr('disabled', false);
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
                $('#update_result_announcer').modal('toggle');
                $('#ResultAnnouncerTable').DataTable().ajax.reload();
            }
        }
    });
});
</script>