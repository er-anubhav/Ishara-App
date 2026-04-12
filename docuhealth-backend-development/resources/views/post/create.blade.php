<!DOCTYPE html>
<html class="loading" lang="en" data-textdirection="ltr">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0">
    <title>Market Add - 888Playwin<</title>
@include('admin.layout.header')
<style>
  table td, table th {
    padding: 00.5rem 0.5rem !important;
  }
  .add-market-time-btn{
    position: relative;
    top: 13px;
    float: right;
  }
</style>
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
                    <div class="form-group">
                      <label class="text-bold-600">Heading</label>
                      <input type="text" class="form-control" name="heading" placeholder="Enter Heading">
                    </div>
                  </div>
                  <div class="col-12">
                    <div class="form-group">
                      <label class="text-bold-600">Description</label>
                      <textarea class="form-control" name="description" placeholder="Enter Description" style="min-height: 100px;"></textarea>
                    </div>
                  </div>

                  <div class="col-12"><div class="form-group">
                    <label class="text-bold-600">Category</label>
                      <select name="category" id="category">
                        <option value=""></option>
                        @foreach($categories as $category)
                        <option value="{{$category->id}}">{{$category->name}}</option>
                        @endforeach
                      </select>
                    </div>
                  </div>

                  <div class="col-12"><div class="form-group">
                    <label class="text-bold-600">Tags</label>
                      <select name="tags[]" id="tags" multiple>
                        <option value=""></option>
                        @foreach($tags as $tag)
                        <option value="{{$tag->id}}">{{$tag->name}}</option>
                        @endforeach
                      </select>
                    </div>
                  </div>
                  
                  <div class="col-12">
                    <div class="form-group">
                      <label for="content">Content</label>
                      <div class="position-relative has-icon-left">
                        <textarea id="content" name="content" style="display:none;">
                                  <p>This is some sample content.</p>
                        </textarea>
                      </div>
                    </div>
                  </div>

                  <div class="col-12">
                    <div class="form-group">
                      <label for="content">Image</label>
                      <div class="position-relative has-icon-left">
                        <input type="file" name="image" id="image" class="form-control-file">
                      </div>
                    </div>
                  </div>
                </div>
                <div class="mb-1 mt-2" style="float:right;">
                  <button type="reset" class="btn btn-outline-danger mr-1 reset-btn">Cancel</button>
                  <button type="button" class="btn btn-secondary add-btn">Create</button>
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
<script src="https://cdn.ckeditor.com/ckeditor5/34.0.0/classic/ckeditor.js"></script>
<script>
$(document).ready( function () {

    defaultChange = false;
    
    $('#category').select2({
      placeholder: "-- select category --",
      width:"100%"
    });

    $('#tags').select2({
      placeholder: "-- select multiple tags --",
      width:"100%"
    });

    let ckEditorData = '';
    
    function initCKEditor() {
        ClassicEditor
            .create( document.querySelector( '#content' ),{
                toolbar: {
                        items: ['heading', '|', 'bold', 'italic', '|', 'bulletedList', 'numberedList', '|', 'undo', 'redo']
                    },

                typing: {
                    transformations: {
                        remove: [
                            // Do not use the transformations from the
                            // 'symbols' and 'quotes' groups.
                            'symbols',
                            'quotes',

                            // As well as the following transformations.
                            'arrowLeft',
                            'arrowRight'
                        ],

                        extra: [
                            // Add some custom transformations – e.g. for emojis.
                            { from: ':)', to: '🙂' },
                            { from: ':+1:', to: '👍' },
                            { from: ':tada:', to: '🎉' },

                            // You can also define patterns using regular expressions.
                            // Note: The pattern must end with `$` and all its fragments must be wrapped
                            // with capturing groups.
                            // The following rule replaces ` "foo"` with ` «foo»`.
                            {
                                from: /(^|\s)(")([^"]*)(")$/,
                                to: [ null, '«', null, '»' ]
                            },

                            // Finally, you can define `to` as a callback.
                            // This (naive) rule will auto-capitalize the first word after a period, question mark, or an exclamation mark.
                            {
                                from: /([.?!] )([a-z])$/,
                                to: matches => [ null, matches[ 1 ].toUpperCase() ]
                            },
                        ],
                    }},
            },)
            .then( value => { window.editor = value; ckEditorData = value;
            })
            .catch( error => {
                console.error( error );
            });
    }

    initCKEditor();

    //create page action function.
    $(document).on('click', '.add-btn', function() {

      //get and set the from data.
      var myform = document.getElementById("add_data");
      var formData = new FormData(myform);
      
      formData.append('total_data', timing_div);
      formData.append('_token', '{{ csrf_token() }}');

      $(this).html('Creating...').attr('disabled', true);
      $.ajax({
          type: "post",
          data: formData,
          cache:false,
          contentType: false,
          processData: false,
          url: "{{url('market/add')}}",
          success: function(result) {
              $('.add-btn').html('Create').attr('disabled', false);
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
                  $('#add_new').modal('toggle');
                  document.getElementById('add_data').reset();
                  location.replace("{{url('market/list')}}");
              }
          }
      });
    });

    const get_game_type = () => {

        $.ajax({
              type: "get",
              url: "{{url('market/game-type/get')}}",
              success: function(result) {
                console.log(result);
                  if (result.error == true) {
                      Toast.fire({
                        icon: 'error',
                        title: result.message
                      })
                  }else{
                      var html = '<option value=""></option>';

                      for (var i = 0; i < result.data.length; i++) {
                        html += `<option value="${result.data[i]['id']}|${result.data[i]['name']}">${result.data[i]['name']}</option>`;
                      }
                      $('#game_type').html(html);
                  }
              }
          });
    }

    get_game_type();
});
</script>

</body>
</html>