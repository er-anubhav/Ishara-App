<!--Add Banner Modal -->
<div class="modal fade text-left" id="add_specialization" tabindex="-1" role="dialog"
  aria-hidden="true">
  <div class="modal-dialog modal-dialog-top modal-dialog-scrollable modal-lg">
    <div class="modal-content">
      <div class="modal-header">
        <h4 class="modal-title">Add Specialization</h4>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <i class="bx bx-x"></i>
        </button>
      </div>
      <div class="modal-body">
        <form class="form form-vertical" id="add_specialization_data" enctype="multipart/form-data">
          @csrf
          <div class="form-body">
            <div class="row">
              <div class="col-12">
                <div class="form-group">
                  <label for="add_specialization_icon">Icon</label>
                  <div class="position-relative has-icon-left">
                    <input type="file" class="form-control-file" id="add_specialization_icon" name="icon">
                  </div>
                </div>
              </div>
              <div class="col-12">
                <div class="form-group">
                  <label for="add_specialization_name">Name</label>
                  <div class="position-relative has-icon-left">
                    <input type="text" id="add_specialization_name" class="form-control" name="name" placeholder="Enter Specialization Name">
                    <div class="form-control-position">
                      <i class='bx bxs-rename'></i>
                    </div>
                  </div>
                </div>
              </div>
              <div class="col-12">
                <div class="form-group">
                  <label for="add_specialization_fraction">Postion</label>
                  <div class="position-relative has-icon-left">
                    <input type="number" id="add_specialization_position" class="form-control" name="position" placeholder="Enter Specialization position">
                    <div class="form-control-position">
                      <i class='bx bxs-label' ></i>
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
        <button type="button" class="btn btn-primary ml-1 add-specialization-btn">
          <i class="bx bx-check d-block d-sm-none"></i>
         Add
        </button>
      </div>
    </div>
  </div>
</div>
<script>
$(document).on('click', '.add-specialization-btn', function() {

    //get and set the from data.
    var myform = document.getElementById("add_specialization_data");
    var formData = new FormData(myform);
    formData.append('_token', '{{ csrf_token() }}');

    $('#add_specialization_data :file').each(function() {
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
        url: "{{url('/')}}/{{$auth_path}}/specializations",
        success: function(result) {
            $('.add-specialization-btn').html('Add').attr('disabled', false);
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
                $('#add_specialization').modal('toggle');
                $('#SpecializationTable').DataTable().ajax.reload();
            }
        }
    });
});
</script>