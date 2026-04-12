<!--Add Banner Modal -->
<div class="modal fade text-left" id="add_category" tabindex="-1" role="dialog"
  aria-hidden="true">
  <div class="modal-dialog modal-dialog-top modal-dialog-scrollable modal-lg">
    <div class="modal-content">
      <div class="modal-header">
        <h4 class="modal-title">Add Category</h4>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <i class="bx bx-x"></i>
        </button>
      </div>
      <div class="modal-body">
        <form class="form form-vertical" id="add_category_data" enctype="multipart/form-data">
          @csrf
          <div class="form-body">
            <div class="row">
              <div class="col-12">
                <div class="form-group">
                  <label for="add_category_icon">Icon</label>
                  <div class="position-relative has-icon-left">
                    <input type="file" class="form-control-file" id="add_category_icon" name="icon">
                  </div>
                </div>
              </div>
              <div class="col-12">
                <div class="form-group">
                  <label for="add_category_name">Name</label>
                  <div class="position-relative has-icon-left">
                    <input type="text" id="add_category_name" class="form-control" name="name" placeholder="Enter Category Name">
                    <div class="form-control-position">
                      <i class='bx bxs-rename'></i>
                    </div>
                  </div>
                </div>
              </div>
              <div class="col-12">
                <div class="form-group">
                  <label for="add_category_fraction">Postion</label>
                  <div class="position-relative has-icon-left">
                    <input type="number" id="add_category_position" class="form-control" name="position" placeholder="Enter Category position">
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
        <button type="button" class="btn btn-primary ml-1 add-category-btn">
          <i class="bx bx-check d-block d-sm-none"></i>
         Add
        </button>
      </div>
    </div>
  </div>
</div>
<script>
$(document).on('click', '.add-category-btn', function() {

    //get and set the from data.
    var myform = document.getElementById("add_category_data");
    var formData = new FormData(myform);
    formData.append('_token', '{{ csrf_token() }}');
          
    $.ajax({
        type: "post",
        data: formData,
        url: "{{url('/')}}{{$auth_path}}/categories",
        success: function(result) {
            if (result.success == false) {
                alert(result.message);
            }else{
                alert(result.message);
            }
        }
    });
});
</script>