<div class="modal inmodal" id="user_password_change_modal" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog">
    <div class="modal-content animated bounceInRight">
            <div class="modal-header" style="padding: 20px 15px;">
                <h4 class="modal-title">Change User Password</h4>
            </div>
            <form id="user_password_form">
                @csrf
                <input type="hidden" name="user_id" id="user_id">
            <div class="modal-body">
                <div class="form-group">
                  <label>Password</label>
                  <input type="password" name="password" class="form-control view-from left-border" autocomplete="off">
                </div>
                <hr class="mt-2">
                <div class="form-group">
                  <label>Confirm Password</label>
                  <input type="password" name="confirm_password" class="form-control view-from left-border" autocomplete="off">
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-danger" data-dismiss="modal">Close</button>
                <button type="button" class="btn btn-primary update-user-password-btn">Change</button>
            </div>
            </form>
        </div>
    </div>
</div>

<script>
$(document).ready( function () {

  $(document).on('click', '.update-user-password', function() {
    let id = $(this).attr('data-value');
    $('#user_password_form #user_id').val(id);
    $('#user_password_change_modal').modal('show');
  });

  $(document).on('click', '#user_password_change_modal .update-user-password-btn', function() {

      $.ajax({
              type: "post",
              url: "{{url('users/password-change')}}",
              data: $('#user_password_form').serialize(),
              success: function(result) {

                  if (result.error == true) {
                      Swal.fire(result.message, '', 'error');
                  }else{
                    Swal.fire(result.message, '', 'success');
                    $('#user_password_form #user_id').val(0);
                    document.getElementById('user_password_form').reset();
                    $('#user_password_change_modal').modal('hide');
                  }
              }
        });
  });

});
</script>
