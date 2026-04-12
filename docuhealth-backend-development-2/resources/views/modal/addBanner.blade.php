<?php
$auth = auth()->user()->role;
$auth_path = auth()->user()->role == 'Admin' ? '/admin' : '' ;
?>
<!--Add Banner Modal -->
<div class="modal fade text-left" id="add_new_banner" tabindex="-1" role="dialog"
  aria-hidden="true">
  <div class="modal-dialog modal-dialog-top modal-dialog-scrollable modal-lg">
    <div class="modal-content">
      <div class="modal-header">
        <h4 class="modal-title">Add Banner</h4>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <i class="bx bx-x"></i>
        </button>
      </div>
      <div class="modal-body">
        <form class="form form-vertical" id="add_banner_data" enctype="multipart/form-data">
          @csrf
          <div class="form-body">
            <div class="row">
              <div class="col-12">
                <div class="form-group">
                  <label for="add_banner_image">Image</label>
                  <div class="position-relative has-icon-left">
                    <input type="file" class="form-control-file" id="add_banner_image" name="banner_image">
                  </div>
                </div>
              </div>
              <div class="col-12">
                <div class="form-group">
                  <label for="add_banner_position">Banner Position</label>
                  <div class="position-relative has-icon-left">
                    <input type="number" id="add_banner_position" class="form-control" name="banner_position" placeholder="e.g. 1">
                    <div class="form-control-position">
                      <i class="bx bx-mobile"></i>
                    </div>
                  </div>
                </div>
              </div>
              <div class="col-12">
                <div class="form-group">
                  <label for="add_banner_url">Slug/Link</label>
                  <div class="position-relative has-icon-left">
                    <input type="text" id="add_banner_url" class="form-control" name="banner_url" placeholder="Enter Banner Slug or Link.">
                    <div class="form-control-position">
                      <i class="bx bx-mobile"></i>
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
        <button type="button" class="btn btn-primary ml-1 add-banner-btn">
          <i class="bx bx-check d-block d-sm-none"></i>
         Add
        </button>
      </div>
    </div>
  </div>
</div>
<script>
$(document).on('click', '.add-banner-btn', function() {

    //get and set the from data.
    var myform = document.getElementById("add_banner_data");
    var formData = new FormData(myform);
    formData.append('_token', '{{ csrf_token() }}');

    $('#add_banner_data :file').each(function() {
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
        url: "{{url('/')}}{{$auth_path}}/banners",
        success: function(result) {
            $('.add-banner-btn').html('Add').attr('disabled', false);
            if (result.success == false) {
                Toast.fire({
                  icon: 'error',
                  title: result.message
                })
            }else{
                Toast.fire({
                  icon: 'success',
                  title: result.message
                })
                $('#add_new_banner').modal('toggle');
                $('#BannerTable').DataTable().ajax.reload();
            }
        }
    });
});
</script>