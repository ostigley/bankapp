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
    var transactionIds = transactions.map(function(i,t) {
      return $(t.parentElement).data().id
    }).toArray();

    $.ajax({
      beforeSend: function (xhr) {
        xhr.setRequestHeader('X-CSRF-Token', token)
      },
      dataType: 'json',
      data: {
        "transaction" : {
          "ids": transactionIds,
          "detail": transactionDetail,
          "category": newCategory
        }
      },
      type: 'POST',
      url: '/transactions/edit',
      complete: function(data) {
        if (data.status == 200) {
         $("form[data-detail=" + transactionDetail + "]").hide()
        } else {
          alert('something went wrong')
          console.log(data)
        }
      },
    });
  }));
});