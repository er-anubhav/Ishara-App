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
    <title>About - Docuhealth<</title>
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
              <form method="POST" id="add_data">
                @csrf
                <div class="row">

                <div class="col-12">
                    <label class="text-bold-600">Page Content</label>
                  <div id="editor">
                  </div>
                </div>
                
                </div>
                <div class="mb-1 mt-2" style="float:right;">
                  <button type="reset" class="btn btn-outline-danger mr-1 reset-btn">Cancel</button>
                  <button type="button" class="btn btn-secondary add-btn">Save</button>
                </div>
              </form>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</section>
</div></div></div>
<div class="sidenav-overlay"></div>
<div class="drag-target"></div>
@include('admin.layout.footer')

<script src="https://cdn.ckeditor.com/ckeditor5/31.0.0/classic/ckeditor.js"></script>

<script>
$(document).ready( function () {

    var myEditor;

    //create page action function.
    $(document).on('click', '.add-btn', function() {

        var content = myEditor.getData();
        //get and set the from data.
        var myform = document.getElementById("add_data");
        var formData = new FormData(myform);
        
        formData.append('_token', '{{ csrf_token() }}');
        formData.append('content', content);

        $(this).html('Saving...').attr('disabled', true);
        $.ajax({
            type: "post",
            data: formData,
            cache:false,
            contentType: false,
            processData: false,
            url: "{{url('/')}}/{{$auth_path}}/cms/privacy-policy",
            success: function(result) {
                $('.add-btn').html('Create').attr('disabled', false);
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
                }
            }
        });
    });

    //reset the form.
    $(document).on('click', '.reset-btn', function() {
      myEditor.data.set('');
      $('#add_keywords').html('<option value=""></option>').val("").trigger('change');
    });

    get_cms();

    function get_cms() {
      
      try{
        $.ajax({
            type: "get",
            url: "{{url('/get-cms')}}/privacy-policy-page",
            success: function(result) {
              let data = result.data;
              $('#editor').html('');
              if(data){
                $('#editor').html(data.content);
              }
              
              ClassicEditor.create( document.querySelector( '#editor' ) )
              .then( editor => {
                     console.log( 'Editor was initialized', editor );
                     myEditor = editor;
              })
              .catch( error => {
                      console.error( error );
              });

            }
        });
      }catch(e){
        ClassicEditor.create( document.querySelector( '#editor' ) )
              .then( editor => {
                     console.log( 'Editor was initialized', editor );
                     myEditor = editor;
              })
              .catch( error => {
                      console.error( error );
              });
      }
    }
});
</script>

</body>
</html>