$(function() {
  var token = $('meta[name="csrf-token"]').attr('content');
  $('input.submit').on('click', (function(e) {
    e.preventDefault();
    var newCategory = $(this.parentElement).serializeArray()
                        .find(function(field) {
                          return field.name === 'new_category'
                        })
                      .value;

    var transactionDetail = $(this.parentElement).data().detail;
    var transactions = $("input[data-detail=" + transactionDetail + "]");

    transactions.each(function() {
      var form =  $(this.parentElement)
      var transactionId = form.data().id;
      this.value = newCategory;

      $.ajax({
        beforeSend: function (xhr) {
          xhr.setRequestHeader('X-CSRF-Token', token)
        },
        dataType: 'json',
        data: {
          "transaction" : {
            "id": transactionId,
            "detail": transactionDetail,
            "category": newCategory
          }
        },
        type: 'POST',
        url: '/transactions/edit',
        success: function(data) {
        },
        complete: function(data) {
          if (data.status == 200) {
           form.hide();
          }
        },
      });
    })
  }));
});