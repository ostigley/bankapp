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

    postCategory(transactionIds, newCategory, transactionDetail)
    $('select').append($('<option>', {
      value: newCategory,
      text: newCategory
    }));
  }));

  $('select').on('change', function(){
    // todo
    // options should be uniq, not repeated categories
    // select change finds all others like it(by form parent data-detail) (as above)
    var category = this.options[this.options.selectedIndex].text
    var id = $(this.parentElement).data().id

    postCategory([id], category)
  })

  function postCategory(ids, category, detail, parentElement) {
    $.ajax({
      beforeSend: function (xhr) {
        xhr.setRequestHeader('X-CSRF-Token', token)
      },
      dataType: 'json',
      data: {
        "transactions" : {
          "ids": ids,
          "category": category,
          "detail": detail,
        }
      },
      type: 'POST',
      url: '/transactions/edit',
      complete: function(data) {
        if (data.status == 200) {
          ids.map(function(id) {
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