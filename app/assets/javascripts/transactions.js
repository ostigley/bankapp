$(function() {
  var token = $('meta[name="csrf-token"]').attr('content');
  $('input.submit').on('click', (function(e) {
    e.preventDefault();
    var newCategory = $(this.parentElement).serializeArray()
                        .find(function(field) {
                          return field.name === 'new_category'
                        })
                      .value;

    postCategory(this, newCategory);
    $('select').append($('<option>', {
      value: newCategory,
      text: newCategory
    }));
  }));

  $('select').on('change', function(){
    var category = this.options[this.options.selectedIndex].text;
    var id = $(this.parentElement).data().id;

    postCategory(this, category);
  })

  function postCategory(element, category) {
    var transactionDetail = $(element.parentElement).data().detail;
    var transactions = $("input[data-detail=" + transactionDetail + "]");
    var transactionIds = transactions.map(function(i,t) {
      return $(t.parentElement).data().id
    }).toArray();

    $.ajax({
      beforeSend: function (xhr) {
        xhr.setRequestHeader('X-CSRF-Token', token);
      },
      dataType: 'json',
      data: {
        "transactions" : {
          "ids": transactionIds,
          "category": category,
          "detail": transactionDetail,
        }
      },
      type: 'POST',
      url: '/transactions/edit',
      complete: function(data) {
        if (data.status == 200) {
          transactionIds.map(function(id) {
            $("form[data-id=" + id + "]").hide();
          });
        } else {
          alert('something went wrong');
          console.log(data);
        }
      },
    });
  }
});