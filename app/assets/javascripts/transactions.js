$(function() {
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
      this.value = newCategory;
    })
  }));
});