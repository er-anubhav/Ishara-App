<!--Add Banner Modal -->
<div class="modal fade text-left" id="add_tags_modal" tabindex="-1" role="dialog"
  aria-hidden="true">
  <div class="modal-dialog modal-dialog-top modal-dialog-scrollable modal-lg">
    <div class="modal-content">
      <div class="modal-header">
        <h4 class="modal-title">Add Result Announcer</h4>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <i class="bx bx-x"></i>
        </button>
      </div>
      <div class="modal-body">
        <form class="form form-vertical" id="add_tags_data" enctype="multipart/form-data">
          @csrf
          <div class="form-body">
            <div class="row">
              <div class="col-12">
                <div class="form-group">
                  <label for="add_tags_name">Name</label>
                  <div class="position-relative has-icon-left">
                    <input type="text" id="add_tags_name" class="form-control" name="name" placeholder="Enter Name">
                    <div class="form-control-position">
                      <i class='bx bxs-rename'></i>
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
        <button type="button" class="btn btn-primary ml-1 add-finance-manger-btn">
          <i class="bx bx-check d-block d-sm-none"></i>
         Add
        </button>
      </div>
    </div>
  </div>
</div>
<script>
$(document).on('click', '.add-finance-manger-btn', function() {

          //get and set the from data.
          var myform = document.getElementById("add_tags_data");
          var formData = new FormData(myform);
          formData.append('_token', '{{ csrf_token() }}');

          $(this).html('Saving...').attr('disabled', true);
          $.ajax({
              type: "post",
              data: formData,
              cache:false,
              contentType: false,
              processData: false,
              url: "{{url('/')}}{{$auth_path}}/tags",
              success: function(result) {
                  $('.add-finance-manger-btn').html('Add').attr('disabled', false);
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
                      $('#TagTable').DataTable().ajax.reload();
                      $('#add_tags_modal').modal('toggle');
                  }
              }
          });
    });
</script>