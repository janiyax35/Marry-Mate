/**
 * Budget Planner JavaScript - Marry Mate Wedding Planning System
 * Current Date and Time: 2025-05-01 08:13:25
 * Current User: IT24102137
 */

// Ensure document is fully loaded before running code
$(document).ready(function() {
    'use strict';
    
    console.log("Budget Planner JS initialized"); // Debug log
    
    // Initialize DataTables
    initDataTables();
    
    // Initialize date pickers
    initDatePickers();
    
    // Initialize Charts
    initCharts();
    
    // Initialize Budget Planner event handlers
    initEventHandlers();
    
    // Initialize tooltips and popovers
    initTooltips();
});

/**
 * Initialize DataTables plugin
 */
function initDataTables() {
    console.log("Initializing DataTables"); // Debug log
    
    try {
        if ($.fn.DataTable) {
            $('#expensesTable').DataTable({
                responsive: true,
                dom: '<"top"fl>rt<"bottom"ip><"clear">',
                language: {
                    search: "_INPUT_",
                    searchPlaceholder: "Search expenses...",
                    lengthMenu: "Show _MENU_ entries",
                    info: "Showing _START_ to _END_ of _TOTAL_ expenses",
                    infoEmpty: "Showing 0 to 0 of 0 expenses",
                    infoFiltered: "(filtered from _MAX_ total expenses)"
                },
                columnDefs: [
                    { responsivePriority: 1, targets: 1 },
                    { responsivePriority: 2, targets: 4 },
                    { responsivePriority: 3, targets: 6 },
                    { orderable: false, targets: 6 }
                ],
                order: [[3, 'desc']] // Sort by date in descending order by default
            });
            console.log("DataTable initialized successfully");
        } else {
            console.error("DataTables plugin not available");
        }
    } catch (e) {
        console.error("Error initializing DataTables:", e);
    }
}

/**
 * Initialize Date Pickers
 */
function initDatePickers() {
    console.log("Initializing date pickers"); // Debug log
    
    try {
        if (typeof flatpickr === 'function') {
            flatpickr('#expenseDate', {
                dateFormat: 'Y-m-d',
                defaultDate: 'today',
                allowInput: true
            });
            console.log("Date pickers initialized successfully");
        } else {
            console.error("flatpickr is not defined - check if the library is loaded");
        }
    } catch (e) {
        console.error("Error initializing date pickers:", e);
    }
}

/**
 * Initialize Charts
 */
function initCharts() {
    console.log("Initializing charts"); // Debug log
    
    try {
        // Initialize Budget Pie Chart
        initBudgetPieChart();
        
        // Initialize Spending Line Chart
        initSpendingLineChart();
    } catch (e) {
        console.error("Error initializing charts:", e);
    }
}

/**
 * Initialize Budget Pie Chart
 */
function initBudgetPieChart() {
    const budgetPieChartElem = document.getElementById('budgetPieChart');
    
    if (budgetPieChartElem) {
        // Collect data from the budget categories table
        const categories = [];
        const budgetAmounts = [];
        const spentAmounts = [];
        const remainingAmounts = [];
        const backgroundColors = [];
        
        $('.budget-categories-table tbody tr').each(function() {
            const categoryName = $(this).find('td:first-child').text().trim();
            const budgetAmount = parseFloat($(this).find('.budget-amount').text().replace('$', '').replace(',', ''));
            const spentAmount = parseFloat($(this).find('.spent-amount').text().replace('$', '').replace(',', ''));
            const remainingAmount = parseFloat($(this).find('.remaining-amount').text().replace('$', '').replace(',', ''));
            const bgColor = $(this).find('.category-color-dot').css('background-color');
            
            categories.push(categoryName);
            budgetAmounts.push(budgetAmount);
            spentAmounts.push(spentAmount);
            remainingAmounts.push(remainingAmount);
            backgroundColors.push(bgColor);
        });
        
        // Create the pie chart
        const budgetPieChart = new Chart(budgetPieChartElem, {
            type: 'doughnut',
            data: {
                labels: categories,
                datasets: [{
                    data: budgetAmounts,
                    backgroundColor: backgroundColors,
                    borderWidth: 2,
                    borderColor: 'white'
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: {
                            font: {
                                size: 12
                            },
                            boxWidth: 15
                        }
                    },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                const label = context.label || '';
                                const value = context.raw;
                                const total = context.dataset.data.reduce((acc, val) => acc + val, 0);
                                const percentage = Math.round((value / total) * 100);
                                return `${label}: $${value.toLocaleString()} (${percentage}%)`;
                            }
                        }
                    }
                }
            }
        });
    }
}

/**
 * Initialize Spending Line Chart
 */
function initSpendingLineChart() {
    const spendingLineChartElem = document.getElementById('spendingLineChart');
    
    if (spendingLineChartElem) {
        // Process expense data to create a spending timeline
        const expenses = processExpensesForChart();
        
        // Create the line chart
        const spendingLineChart = new Chart(spendingLineChartElem, {
            type: 'line',
            data: {
                labels: expenses.dates,
                datasets: [{
                    label: 'Cumulative Spending',
                    data: expenses.cumulativeAmounts,
                    borderColor: '#1a365d',
                    backgroundColor: 'rgba(26, 54, 93, 0.1)',
                    fill: true,
                    tension: 0.3,
                    pointRadius: 3,
                    pointBackgroundColor: '#1a365d'
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    x: {
                        grid: {
                            display: false
                        }
                    },
                    y: {
                        beginAtZero: true,
                        ticks: {
                            callback: function(value) {
                                return '$' + value.toLocaleString();
                            }
                        }
                    }
                },
                plugins: {
                    legend: {
                        display: false
                    },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                const value = context.raw;
                                return `Spent: $${value.toLocaleString()}`;
                            }
                        }
                    }
                }
            }
        });
    }
}

/**
 * Process Expense Data for Chart
 * @returns {Object} - Object with dates and cumulative amounts
 */
function processExpensesForChart() {
    // Get expenses from table
    const expensesData = [];
    
    $('#expensesTable tbody tr').each(function() {
        const date = $(this).find('td:eq(3)').text().trim();
        const amount = parseFloat($(this).find('.expense-amount').text().replace('$', '').replace(',', ''));
        
        expensesData.push({ date, amount });
    });
    
    // Sort by date
    expensesData.sort((a, b) => new Date(a.date) - new Date(b.date));
    
    // Create cumulative spending data
    const dates = [];
    const cumulativeAmounts = [];
    let runningTotal = 0;
    
    expensesData.forEach(expense => {
        runningTotal += expense.amount;
        dates.push(expense.date);
        cumulativeAmounts.push(runningTotal);
    });
    
    return { dates, cumulativeAmounts };
}

/**
 * Initialize Event Handlers
 */
function initEventHandlers() {
    console.log("Setting up event handlers"); // Debug log
    
    // Add Category Button
    $(document).on('click', '#addCategoryBtn', function(e) {
        e.preventDefault();
        console.log("Add category button clicked");
        
        // Reset form and show modal
        resetCategoryForm();
        $('#categoryModalTitle').text('Add Category');
        $('#categoryModal').modal('show');
    });
    
    // Edit Category Button
    $(document).on('click', '.edit-category-btn', function(e) {
        e.preventDefault();
        const categoryId = $(this).data('id');
        console.log("Edit category button clicked for ID:", categoryId);
        
        // Populate form with category data
        populateCategoryForm(categoryId);
        $('#categoryModalTitle').text('Edit Category');
        $('#categoryModal').modal('show');
    });
    
    // Delete Category Button
    $(document).on('click', '.delete-category-btn', function(e) {
        e.preventDefault();
        const categoryId = $(this).data('id');
        const categoryName = $(this).closest('tr').find('td:first').text().trim();
        console.log("Delete category button clicked for ID:", categoryId);
        
        // Confirm deletion
        Swal.fire({
            title: 'Delete Category?',
            text: `Are you sure you want to delete the "${categoryName}" category and all associated expenses? This action cannot be undone.`,
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#dc3545',
            cancelButtonColor: '#6c757d',
            confirmButtonText: 'Yes, delete it!',
            cancelButtonText: 'Cancel'
        }).then((result) => {
            if (result.isConfirmed) {
                // Delete the category - in a real app this would be an AJAX call
                deleteCategory(categoryId);
            }
        });
    });
    
    // Save Category Button
    $(document).on('click', '#saveCategoryBtn', function(e) {
        e.preventDefault();
        console.log("Save category button clicked");
        
        // Validate form
        if (!validateForm('#categoryForm')) {
            return;
        }
        
        // Show loading state
        const btn = $(this);
        const originalText = btn.text();
        btn.html('<i class="fas fa-spinner fa-spin me-1"></i> Saving...');
        btn.prop('disabled', true);
        
        // Get form data
        const categoryId = $('#categoryId').val();
        const categoryName = $('#categoryName').val();
        const categoryBudget = parseFloat($('#categoryBudget').val());
        const categoryColor = $('#categoryColor').val();
        
        // Save the category - in a real app this would be an AJAX call
        setTimeout(() => {
            if (categoryId) {
                // Update existing category
                updateCategory(categoryId, categoryName, categoryBudget, categoryColor);
            } else {
                // Add new category
                addCategory(categoryName, categoryBudget, categoryColor);
            }
            
            // Reset button state
            btn.html(originalText);
            btn.prop('disabled', false);
            
            // Close modal
            $('#categoryModal').modal('hide');
            
            // Show success message
            const action = categoryId ? 'updated' : 'added';
            Swal.fire({
                title: 'Success!',
                text: `Category "${categoryName}" has been ${action} successfully.`,
                icon: 'success',
                confirmButtonColor: '#1a365d'
            });
        }, 1000);
    });
    
    // Add Expense Buttons (both in header and top)
    $(document).on('click', '#addExpenseBtn, #addExpenseBtnAlt', function(e) {
        e.preventDefault();
        console.log("Add expense button clicked");
        
        // Reset form and show modal
        resetExpenseForm();
        $('#expenseModalTitle').text('Add Expense');
        $('#expenseModal').modal('show');
    });
    
    // Edit Expense Button
    $(document).on('click', '.edit-expense-btn', function(e) {
        e.preventDefault();
        const expenseId = $(this).data('id');
        console.log("Edit expense button clicked for ID:", expenseId);
        
        // Populate form with expense data
        populateExpenseForm(expenseId);
        $('#expenseModalTitle').text('Edit Expense');
        $('#expenseModal').modal('show');
    });
    
    // Delete Expense Button
    $(document).on('click', '.delete-expense-btn', function(e) {
        e.preventDefault();
        const expenseId = $(this).data('id');
        const vendorName = $(this).closest('tr').find('td:eq(1)').text().trim();
        console.log("Delete expense button clicked for ID:", expenseId);
        
        // Confirm deletion
        Swal.fire({
            title: 'Delete Expense?',
            text: `Are you sure you want to delete the expense for "${vendorName}"? This action cannot be undone.`,
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#dc3545',
            cancelButtonColor: '#6c757d',
            confirmButtonText: 'Yes, delete it!',
            cancelButtonText: 'Cancel'
        }).then((result) => {
            if (result.isConfirmed) {
                // Delete the expense - in a real app this would be an AJAX call
                deleteExpense(expenseId);
            }
        });
    });
    
    // Save Expense Button
    $(document).on('click', '#saveExpenseBtn', function(e) {
        e.preventDefault();
        console.log("Save expense button clicked");
        
        // Validate form
        if (!validateForm('#expenseForm')) {
            return;
        }
        
        // Show loading state
        const btn = $(this);
        const originalText = btn.text();
        btn.html('<i class="fas fa-spinner fa-spin me-1"></i> Saving...');
        btn.prop('disabled', true);
        
        // Get form data
        const expenseId = $('#expenseId').val();
        const categoryId = $('#expenseCategory').val();
        const vendor = $('#expenseVendor').val();
        const description = $('#expenseDescription').val();
        const date = $('#expenseDate').val();
        const amount = parseFloat($('#expenseAmount').val());
        const status = $('#expenseStatus').val();
        
        // Save the expense - in a real app this would be an AJAX call
        setTimeout(() => {
            if (expenseId) {
                // Update existing expense
                updateExpense(expenseId, categoryId, vendor, description, date, amount, status);
            } else {
                // Add new expense
                addExpense(categoryId, vendor, description, date, amount, status);
            }
            
            // Reset button state
            btn.html(originalText);
            btn.prop('disabled', false);
            
            // Close modal
            $('#expenseModal').modal('hide');
            
            // Show success message
            const action = expenseId ? 'updated' : 'added';
            Swal.fire({
                title: 'Success!',
                text: `Expense for "${vendor}" has been ${action} successfully.`,
                icon: 'success',
                confirmButtonColor: '#1a365d'
            });
        }, 1000);
    });
    
    // Adjust Budget Button
    $(document).on('click', '#adjustBudgetBtn', function(e) {
        e.preventDefault();
        console.log("Adjust budget button clicked");
        
        // Show adjust budget modal
        $('#adjustBudgetModal').modal('show');
    });
    
    // Save Adjusted Budget Button
    $(document).on('click', '#saveAdjustedBudgetBtn', function(e) {
        e.preventDefault();
        console.log("Save adjusted budget button clicked");
        
        // Validate the budget amount
        const totalBudgetAmount = $('#totalBudgetAmount').val();
        if (!totalBudgetAmount || isNaN(totalBudgetAmount) || parseFloat(totalBudgetAmount) <= 0) {
            Swal.fire({
                title: 'Invalid Amount',
                text: 'Please enter a valid budget amount.',
                icon: 'error',
                confirmButtonColor: '#1a365d'
            });
            return;
        }
        
        // Get adjustment type
        const adjustmentType = $('input[name="adjustmentType"]:checked').val();
        
        // Show loading state
        const btn = $(this);
        const originalText = btn.text();
        btn.html('<i class="fas fa-spinner fa-spin me-1"></i> Updating...');
        btn.prop('disabled', true);
        
        // Update budget - in a real app this would be an AJAX call
        setTimeout(() => {
            // Update total budget
            adjustTotalBudget(parseFloat(totalBudgetAmount), adjustmentType);
            
            // Reset button state
            btn.html(originalText);
            btn.prop('disabled', false);
            
            // Close modal
            $('#adjustBudgetModal').modal('hide');
            
            // Show success message
            Swal.fire({
                title: 'Budget Updated!',
                text: 'Your total wedding budget has been updated successfully.',
                icon: 'success',
                confirmButtonColor: '#1a365d'
            });
        }, 1000);
    });
    
    // Export PDF Button
    $(document).on('click', '#exportPDFBtn', function(e) {
        e.preventDefault();
        console.log("Export PDF button clicked");
        
        // Show loading indicator
        Swal.fire({
            title: 'Generating PDF',
            html: 'Please wait while we prepare your PDF...',
            timerProgressBar: true,
            didOpen: () => {
                Swal.showLoading();
            }
        });
        
        // Simulate PDF generation delay
        setTimeout(() => {
            Swal.fire({
                title: 'PDF Ready!',
                text: 'Your budget report has been generated.',
                icon: 'success',
                confirmButtonColor: '#1a365d',
                confirmButtonText: 'Download PDF'
            }).then((result) => {
                if (result.isConfirmed) {
                    // In a real app, this would trigger the download
                    console.log('Downloading PDF...');
                }
            });
        }, 2000);
    });
    
    // Export Excel Button
    $(document).on('click', '#exportExcelBtn', function(e) {
        e.preventDefault();
        console.log("Export Excel button clicked");
        
        // Show loading indicator
        Swal.fire({
            title: 'Generating Excel',
            html: 'Please wait while we prepare your Excel file...',
            timerProgressBar: true,
            didOpen: () => {
                Swal.showLoading();
            }
        });
        
        // Simulate Excel generation delay
        setTimeout(() => {
            Swal.fire({
                title: 'Excel Ready!',
                text: 'Your budget spreadsheet has been generated.',
                icon: 'success',
                confirmButtonColor: '#1a365d',
                confirmButtonText: 'Download Excel'
            }).then((result) => {
                if (result.isConfirmed) {
                    // In a real app, this would trigger the download
                    console.log('Downloading Excel...');
                }
            });
        }, 1800);
    });
    
    // Print Budget Button
    $(document).on('click', '#printBudgetBtn', function(e) {
        e.preventDefault();
        console.log("Print budget button clicked");
        
        // Open print dialog
        window.print();
    });
    
    // Budget Tips Button
    $(document).on('click', '#viewSuggestionsBtn', function(e) {
        e.preventDefault();
        console.log("Budget tips button clicked");
        
        // Show budget tips modal
        $('#budgetTipsModal').modal('show');
    });
    
    // More Tips Button
    $(document).on('click', '#moreTipsBtn', function(e) {
        e.preventDefault();
        console.log("More tips button clicked");
        
        // Simulate loading more tips
        const btn = $(this);
        const originalText = btn.text();
        btn.html('<i class="fas fa-spinner fa-spin me-1"></i> Loading...');
        btn.prop('disabled', true);
        
        setTimeout(() => {
            // Add some new tips
            $('.tips-container').append(`
                <div class="tip-item new-tip">
                    <div class="tip-icon"><i class="fas fa-camera"></i></div>
                    <div class="tip-content">
                        <h5>Photography Packages</h5>
                        <p>Consider booking a photographer for fewer hours instead of a full-day package. Focus on key moments like the ceremony and formal portraits.</p>
                    </div>
                </div>
                <div class="tip-item new-tip">
                    <div class="tip-icon"><i class="fas fa-music"></i></div>
                    <div class="tip-content">
                        <h5>Entertainment Alternatives</h5>
                        <p>Instead of a live band, consider hiring a DJ or create your own playlist. Many venues have sound systems you can connect to.</p>
                    </div>
                </div>
            `);
            
            // Highlight the new tips
            $('.new-tip').addClass('highlight-row');
            setTimeout(() => {
                $('.new-tip').removeClass('highlight-row');
            }, 2000);
            
            // Reset button
            btn.html('More Tips');
            btn.prop('disabled', false);
        }, 1000);
    });
    
    // Search Vendors Button
    $(document).on('click', '#searchVendorsBtn', function(e) {
        e.preventDefault();
        console.log("Search vendors button clicked");
        
        // Redirect to vendor search page
        window.location.href = "../user/vendor-search.jsp";
    });
    
    // Payment Schedule Button
    $(document).on('click', '#paymentScheduleBtn', function(e) {
        e.preventDefault();
        console.log("Payment schedule button clicked");
        
        // Show a modal or redirect to payment schedule page
        Swal.fire({
            title: 'Payment Schedule',
            html: `
                <div class="payment-schedule-view">
                    <table class="table table-sm">
                        <thead>
                            <tr>
                                <th>Vendor</th>
                                <th>Due Date</th>
                                <th>Amount</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>Sunset Beach Resort</td>
                                <td>2025-07-15</td>
                                <td>$1,500.00</td>
                            </tr>
                            <tr>
                                <td>Divine Catering</td>
                                <td>2025-08-10</td>
                                <td>$2,500.00</td>
                            </tr>
                            <tr>
                                <td>Timeless Photography</td>
                                <td>2025-09-01</td>
                                <td>$2,000.00</td>
                            </tr>
                        </tbody>
                    </table>
                    <div class="text-end mt-3">
                        <button id="addPaymentBtn" class="btn btn-sm btn-outline-primary">Add Payment</button>
                    </div>
                </div>
            `,
            showConfirmButton: false,
            showCloseButton: true,
            width: 600
        });
    });
    
    // Share with Partner Button
    $(document).on('click', '#shareWithPartnerBtn', function(e) {
        e.preventDefault();
        console.log("Share with partner button clicked");
        
        // Show share budget modal
        $('#shareBudgetModal').modal('show');
    });
    
    // Send Email Button (in Share Modal)
    $(document).on('click', '#sendEmailBtn', function(e) {
        e.preventDefault();
        console.log("Send email button clicked");
        
        const email = $('#shareEmail').val();
        if (!email || !validateEmail(email)) {
            Swal.fire({
                title: 'Invalid Email',
                text: 'Please enter a valid email address.',
                icon: 'error',
                confirmButtonColor: '#1a365d'
            });
            return;
        }
        
        // Show loading state
        const btn = $(this);
        const originalText = btn.html();
        btn.html('<i class="fas fa-spinner fa-spin me-1"></i> Sending...');
        btn.prop('disabled', true);
        
        // Simulate sending email
        setTimeout(() => {
            // Reset button
            btn.html(originalText);
            btn.prop('disabled', false);
            
            // Clear input
            $('#shareEmail').val('');
            
            // Show success message
            Swal.fire({
                title: 'Budget Shared!',
                text: `Your budget has been shared with ${email}`,
                icon: 'success',
                confirmButtonColor: '#1a365d'
            });
        }, 1500);
    });
    
    // Copy Link Button
    $(document).on('click', '#copyLinkBtn', function(e) {
        e.preventDefault();
        console.log("Copy link button clicked");
        
        // Copy the link to clipboard
        const linkInput = document.getElementById('shareLinkInput');
        linkInput.select();
        document.execCommand('copy');
        
        // Visual feedback
        $(this).html('<i class="fas fa-check me-1"></i> Copied!');
        setTimeout(() => {
            $(this).html('<i class="fas fa-copy me-1"></i> Copy');
        }, 2000);
        
        // Show toast notification
        Swal.mixin({
            toast: true,
            position: 'top-end',
            showConfirmButton: false,
            timer: 3000,
            timerProgressBar: true
        }).fire({
            icon: 'success',
            title: 'Link copied to clipboard'
        });
    });
    
    // Show/hide receipt upload option
    $(document).on('change', '#expenseReceipt', function() {
        $('#receiptUploadContainer').toggle(this.checked);
    });
}

/**
 * Initialize Tooltips
 */
function initTooltips() {
    // Initialize Bootstrap tooltips if available
    try {
        if (typeof bootstrap !== 'undefined' && typeof bootstrap.Tooltip !== 'undefined') {
            const tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]');
            const tooltipList = [...tooltipTriggerList].map(tooltipTriggerEl => new bootstrap.Tooltip(tooltipTriggerEl));
        }
    } catch (e) {
        console.error("Error initializing tooltips:", e);
    }
}

/**
 * Reset Category Form
 */
function resetCategoryForm() {
    $('#categoryForm')[0].reset();
    $('#categoryId').val('');
    $('#categoryColor').val('#1a365d');
}

/**
 * Populate Category Form
 * @param {string} categoryId - ID of the category to edit
 */
function populateCategoryForm(categoryId) {
    const $row = $(`.budget-categories-table tr[data-category-id="${categoryId}"]`);
    
    if ($row.length) {
        $('#categoryId').val(categoryId);
        $('#categoryName').val($row.find('td:first').text().trim());
        $('#categoryBudget').val($row.find('.budget-amount').text().replace('$', '').replace(',', ''));
        $('#categoryColor').val(rgb2hex($row.find('.category-color-dot').css('background-color')));
        $('#categoryNotes').val(''); // In a real app, this would be populated from the database
    }
}

/**
 * Reset Expense Form
 */
function resetExpenseForm() {
    $('#expenseForm')[0].reset();
    $('#expenseId').val('');
    $('#expenseDate').val(new Date().toISOString().split('T')[0]); // Set today's date
    $('#expenseStatus').val('Paid');
    $('#receiptUploadContainer').hide();
}

/**
 * Populate Expense Form
 * @param {string} expenseId - ID of the expense to edit
 */
function populateExpenseForm(expenseId) {
    const $row = $(`#expensesTable tr[data-expense-id="${expenseId}"]`);
    
    if ($row.length) {
        $('#expenseId').val(expenseId);
        $('#expenseCategory').val($row.data('category-id'));
        $('#expenseVendor').val($row.find('td:eq(1)').text().trim());
        $('#expenseDescription').val($row.find('td:eq(2)').text().trim());
        $('#expenseDate').val($row.find('td:eq(3)').text().trim());
        $('#expenseAmount').val($row.find('.expense-amount').text().replace('$', '').replace(',', ''));
        $('#expenseStatus').val($row.find('td:eq(5)').text().trim());
        $('#expensePaymentMethod').val('Credit Card'); // In a real app, this would be from database
        $('#expenseNotes').val(''); // In a real app, this would be from database
        $('#expenseReceipt').prop('checked', false);
        $('#receiptUploadContainer').hide();
    }
}

/**
 * Add Category
 * @param {string} name - Category name
 * @param {number} budget - Budget amount
 * @param {string} color - Category color (hex)
 */
function addCategory(name, budget, color) {
    // In a real app, this would be an AJAX request to save to the database
    // For demo, we'll just add a row to the table
    
    // Generate a unique ID (in a real app, this would come from the server)
    const newId = Math.floor(Math.random() * 1000) + 11;
    
    // Format numbers
    const formattedBudget = budget.toFixed(2);
    const spent = 0;
    const remaining = budget;
    const percentSpent = 0;
    
    // Create row HTML
    const newRow = `
        <tr data-category-id="${newId}">
            <td>
                <span class="category-color-dot" style="background-color: ${color}"></span>
                ${name}
            </td>
            <td class="budget-amount">$${formattedBudget}</td>
            <td class="spent-amount">$0.00</td>
            <td class="remaining-amount">$${formattedBudget}</td>
            <td>
                <div class="progress">
                    <div class="progress-bar" role="progressbar" 
                        style="width: 0%; background-color: ${color}" 
                        aria-valuenow="0" aria-valuemin="0" aria-valuemax="100">
                        0%
                    </div>
                </div>
            </td>
            <td>
                <div class="action-buttons">
                    <button class="btn btn-sm btn-outline-primary edit-category-btn" data-id="${newId}" title="Edit">
                        <i class="fas fa-pencil-alt"></i>
                    </button>
                    <button class="btn btn-sm btn-outline-danger delete-category-btn" data-id="${newId}" title="Delete">
                        <i class="fas fa-trash"></i>
                    </button>
                </div>
            </td>
        </tr>
    `;
    
    // Add the new row to the table
    $('.budget-categories-table tbody').append(newRow);
    
    // Update total budget
    updateTotalBudget();
    
    // Add new option to expense category dropdown
    $('#expenseCategory').append(`<option value="${newId}">${name}</option>`);
    
    // Update charts
    updateCharts();
    
    // Highlight the new row
    $(`.budget-categories-table tr[data-category-id="${newId}"]`).addClass('highlight-row');
    setTimeout(() => {
        $(`.budget-categories-table tr[data-category-id="${newId}"]`).removeClass('highlight-row');
    }, 2000);
}

/**
 * Update Category
 * @param {string} id - Category ID
 * @param {string} name - Category name
 * @param {number} budget - Budget amount
 * @param {string} color - Category color (hex)
 */
function updateCategory(id, name, budget, color) {
    // In a real app, this would be an AJAX request to update in the database
    // For demo, we'll just update the row in the table
    
    const $row = $(`.budget-categories-table tr[data-category-id="${id}"]`);
    
    if ($row.length) {
        // Get current spent amount
        const spent = parseFloat($row.find('.spent-amount').text().replace('$', '').replace(',', '')) || 0;
        
        // Calculate new values
        const remaining = budget - spent;
        const percentSpent = spent > 0 ? Math.min(100, Math.round((spent / budget) * 100)) : 0;
        
        // Update row HTML
        $row.find('td:first').html(`<span class="category-color-dot" style="background-color: ${color}"></span> ${name}`);
        $row.find('.budget-amount').text(`$${budget.toFixed(2)}`);
        $row.find('.remaining-amount').text(`$${remaining.toFixed(2)}`);
        $row.find('.progress-bar').css({
            'width': `${percentSpent}%`,
            'background-color': color
        }).attr('aria-valuenow', percentSpent).text(`${percentSpent}%`);
        
        // Add over-budget warning if needed
        if (spent > budget) {
            $row.find('.remaining-amount').addClass('over-budget');
            $row.find('.progress').addClass('over-budget-progress');
        } else {
            $row.find('.remaining-amount').removeClass('over-budget');
            $row.find('.progress').removeClass('over-budget-progress');
        }
        
        // Update expense category dropdown
        $(`#expenseCategory option[value="${id}"]`).text(name);
        
        // Update total budget
        updateTotalBudget();
        
        // Update charts
        updateCharts();
        
        // Highlight the updated row
        $row.addClass('highlight-row');
        setTimeout(() => {
            $row.removeClass('highlight-row');
        }, 2000);
    }
}

/**
 * Delete Category
 * @param {string} id - Category ID
 */
function deleteCategory(id) {
    // In a real app, this would be an AJAX request to delete from the database
    // For demo, we'll just remove the row from the table
    
    const $row = $(`.budget-categories-table tr[data-category-id="${id}"]`);
    const categoryName = $row.find('td:first').text().trim();
    
    if ($row.length) {
        // Check if there are expenses in this category
        const $expenseRows = $(`#expensesTable tr[data-category-id="${id}"]`);
        
        // If there are expenses, remove them too
        if ($expenseRows.length > 0) {
            $expenseRows.fadeOut(300, function() {
                $(this).remove();
                
                // After all expense rows are removed, update the DataTable
                const table = $('#expensesTable').DataTable();
                table.rows(`[data-category-id="${id}"]`).remove().draw();
            });
        }
        
        // Remove the category row with animation
        $row.fadeOut(300, function() {
            $(this).remove();
            
            // Remove option from expense category dropdown
            $(`#expenseCategory option[value="${id}"]`).remove();
            
            // Update total budget
            updateTotalBudget();
            
            // Update charts
            updateCharts();
            
            // Show success message
            Swal.fire({
                title: 'Deleted!',
                text: `The "${categoryName}" category has been deleted.`,
                icon: 'success',
                confirmButtonColor: '#1a365d'
            });
        });
    }
}

/**
 * Add Expense
 * @param {string} categoryId - Category ID
 * @param {string} vendor - Vendor name
 * @param {string} description - Expense description
 * @param {string} date - Expense date
 * @param {number} amount - Expense amount
 * @param {string} status - Expense status
 */
function addExpense(categoryId, vendor, description, date, amount, status) {
    // In a real app, this would be an AJAX request to save to the database
    // For demo, we'll just add a row to the table
    
    // Generate a unique ID (in a real app, this would come from the server)
    const newId = 'E' + Math.floor(Math.random() * 1000).toString().padStart(3, '0');
    
    // Find category data
    const $categoryRow = $(`.budget-categories-table tr[data-category-id="${categoryId}"]`);
    const categoryName = $categoryRow.find('td:first').text().trim();
    const categoryColor = $categoryRow.find('.category-color-dot').css('background-color');
    
    // Create status badge based on status
    let statusBadge = `<span class="status-badge">${status}</span>`;
    if(status === 'Paid') {
        statusBadge = `<span class="status-badge paid">${status}</span>`;
    } else if(status === 'Pending') {
        statusBadge = `<span class="status-badge pending">${status}</span>`;
    }
    
    // Create new row data
    const rowData = [
        `<span class="category-color-dot" style="background-color: ${categoryColor}"></span> ${categoryName}`,
        vendor,
        description,
        date,
        `<span class="expense-amount">$${amount.toFixed(2)}</span>`,
        statusBadge,
        `<div class="action-buttons">
            <button class="btn btn-sm btn-outline-primary edit-expense-btn" data-id="${newId}" title="Edit">
                <i class="fas fa-pencil-alt"></i>
            </button>
            <button class="btn btn-sm btn-outline-danger delete-expense-btn" data-id="${newId}" title="Delete">
                <i class="fas fa-trash"></i>
            </button>
        </div>`
    ];
    
    // Add the new row to the DataTable
    const table = $('#expensesTable').DataTable();
    const node = table.row.add(rowData).draw().node();
    
    // Add data attributes to the new row
    $(node).attr({
        'data-expense-id': newId,
        'data-category-id': categoryId
    });
    
    // Update category spent amount
    updateCategorySpent(categoryId);
    
    // Update charts
    updateCharts();
    
    // Highlight the new row
    $(node).addClass('highlight-row');
    setTimeout(() => {
        $(node).removeClass('highlight-row');
    }, 2000);
}

/**
 * Update Expense
 * @param {string} id - Expense ID
 * @param {string} categoryId - Category ID
 * @param {string} vendor - Vendor name
 * @param {string} description - Expense description
 * @param {string} date - Expense date
 * @param {number} amount - Expense amount
 * @param {string} status - Expense status
 */
function updateExpense(id, categoryId, vendor, description, date, amount, status) {
    // In a real app, this would be an AJAX request to update in the database
    // For demo, we'll just update the row in the table
    
    const $row = $(`#expensesTable tr[data-expense-id="${id}"]`);
    
    if ($row.length) {
        // Get the old category ID
        const oldCategoryId = $row.data('category-id');
        
        // Find category data for the new category
        const $categoryRow = $(`.budget-categories-table tr[data-category-id="${categoryId}"]`);
        const categoryName = $categoryRow.find('td:first').text().trim();
        const categoryColor = $categoryRow.find('.category-color-dot').css('background-color');
        
        // Create status badge based on status
        let statusBadge = `<span class="status-badge">${status}</span>`;
        if(status === 'Paid') {
            statusBadge = `<span class="status-badge paid">${status}</span>`;
        } else if(status === 'Pending') {
            statusBadge = `<span class="status-badge pending">${status}</span>`;
        }
        
        // Update the DataTable
        const table = $('#expensesTable').DataTable();
        const rowIndex = table.row($row).index();
        
        table.cell(rowIndex, 0).data(`<span class="category-color-dot" style="background-color: ${categoryColor}"></span> ${categoryName}`);
        table.cell(rowIndex, 1).data(vendor);
        table.cell(rowIndex, 2).data(description);
        table.cell(rowIndex, 3).data(date);
        table.cell(rowIndex, 4).data(`<span class="expense-amount">$${amount.toFixed(2)}</span>`);
        table.cell(rowIndex, 5).data(statusBadge);
        
        // Update the row's category ID attribute
        $row.attr('data-category-id', categoryId);
        
        // Redraw the table
        table.draw(false);
        
        // Update category spent amounts (both old and new categories if different)
        if (oldCategoryId !== categoryId) {
            updateCategorySpent(oldCategoryId);
        }
        updateCategorySpent(categoryId);
        
        // Update charts
        updateCharts();
        
        // Highlight the updated row
        $row.addClass('highlight-row');
        setTimeout(() => {
            $row.removeClass('highlight-row');
        }, 2000);
    }
}

/**
 * Delete Expense
 * @param {string} id - Expense ID
 */
function deleteExpense(id) {
    // In a real app, this would be an AJAX request to delete from the database
    // For demo, we'll just remove the row from the table
    
    const $row = $(`#expensesTable tr[data-expense-id="${id}"]`);
    
    if ($row.length) {
        // Get the category ID before removing the row
        const categoryId = $row.data('category-id');
        
        // Remove the row from DataTable
        const table = $('#expensesTable').DataTable();
        table.row($row).remove().draw();
        
        // Update category spent amount
        updateCategorySpent(categoryId);
        
        // Update charts
        updateCharts();
    }
}

/**
 * Update Category Spent Amount
 * @param {string} categoryId - Category ID
 */
function updateCategorySpent(categoryId) {
    // Find all expenses for this category
    let totalSpent = 0;
    
    $(`#expensesTable tr[data-category-id="${categoryId}"]`).each(function() {
        const amount = parseFloat($(this).find('.expense-amount').text().replace('$', '').replace(',', '')) || 0;
        totalSpent += amount;
    });
    
    // Update the category row
    const $categoryRow = $(`.budget-categories-table tr[data-category-id="${categoryId}"]`);
    
    if ($categoryRow.length) {
        // Get budget amount
        const budget = parseFloat($categoryRow.find('.budget-amount').text().replace('$', '').replace(',', '')) || 0;
        
        // Calculate remaining and percent spent
        const remaining = budget - totalSpent;
        const percentSpent = budget > 0 ? Math.min(100, Math.round((totalSpent / budget) * 100)) : 0;
        
        // Update the category row
        $categoryRow.find('.spent-amount').text(`$${totalSpent.toFixed(2)}`);
        $categoryRow.find('.remaining-amount').text(`$${remaining.toFixed(2)}`);
        $categoryRow.find('.progress-bar').css('width', `${percentSpent}%`).attr('aria-valuenow', percentSpent).text(`${percentSpent}%`);
        
        // Add over-budget warning if needed
        if (totalSpent > budget) {
            $categoryRow.find('.remaining-amount').addClass('over-budget');
            $categoryRow.find('.progress-bar').parent().addClass('over-budget-progress');
        } else {
            $categoryRow.find('.remaining-amount').removeClass('over-budget');
            $categoryRow.find('.progress-bar').parent().removeClass('over-budget-progress');
        }
        
        // Update total budget
        updateTotalBudget();
    }
}

/**
 * Update Total Budget
 */
function updateTotalBudget() {
    let totalBudget = 0;
    let totalSpent = 0;
    
    // Calculate totals from all categories
    $('.budget-categories-table tbody tr').each(function() {
        totalBudget += parseFloat($(this).find('.budget-amount').text().replace('$', '').replace(',', '')) || 0;
        totalSpent += parseFloat($(this).find('.spent-amount').text().replace('$', '').replace(',', '')) || 0;
    });
    
    // Calculate remaining and percent
    const totalRemaining = totalBudget - totalSpent;
    const percentSpent = totalBudget > 0 ? Math.min(100, Math.round((totalSpent / totalBudget) * 100)) : 0;
    
    // Update the summary row in the table
    const $summaryRow = $('.budget-categories-table tfoot tr');
    $summaryRow.find('th:eq(1)').text(`$${totalBudget.toFixed(2)}`);
    $summaryRow.find('th:eq(2)').text(`$${totalSpent.toFixed(2)}`);
    $summaryRow.find('th:eq(3)').text(`$${totalRemaining.toFixed(2)}`);
    $summaryRow.find('.progress-bar').css('width', `${percentSpent}%`).attr('aria-valuenow', percentSpent).text(`${percentSpent}%`);
    
    // Update the budget overview cards
    $('.budget-card-total .budget-card-value').text(`$${totalBudget.toFixed(2)}`);
    $('.budget-card-spent .budget-card-value').text(`$${totalSpent.toFixed(2)}`);
    $('.budget-card-spent .budget-card-subtext span').text(`${percentSpent}% of budget`);
    $('.budget-card-remaining .budget-card-value').text(`$${totalRemaining.toFixed(2)}`);
    $('.budget-card-remaining .progress-bar').css('width', `${percentSpent}%`).attr('aria-valuenow', percentSpent);
}

/**
 * Adjust Total Budget
 * @param {number} newBudget - New total budget amount
 * @param {string} adjustmentType - How to adjust category budgets ('proportional' or 'manual')
 */
function adjustTotalBudget(newBudget, adjustmentType) {
    // Get the current total budget
    const currentTotalBudget = parseFloat($('.budget-card-total .budget-card-value').text().replace('$', '').replace(',', '')) || 0;
    
    if (adjustmentType === 'proportional' && currentTotalBudget > 0) {
        // Calculate the ratio for proportional adjustment
        const ratio = newBudget / currentTotalBudget;
        
        // Adjust each category proportionally
        $('.budget-categories-table tbody tr').each(function() {
            const categoryId = $(this).data('category-id');
            const currentBudget = parseFloat($(this).find('.budget-amount').text().replace('$', '').replace(',', '')) || 0;
            const newCategoryBudget = currentBudget * ratio;
            
            // Get other category data
            const categoryName = $(this).find('td:first').text().trim();
            const categoryColor = rgb2hex($(this).find('.category-color-dot').css('background-color'));
            
            // Update the category
            updateCategory(categoryId, categoryName, newCategoryBudget, categoryColor);
        });
    } else {
        // Just update the total budget without adjusting categories
        // In a real app, this would redirect to a page to manually adjust each category
        
        // For demo, we'll just update the total card
        $('.budget-card-total .budget-card-value').text(`$${newBudget.toFixed(2)}`);
        
        // Update the table footer
        const $summaryRow = $('.budget-categories-table tfoot tr');
        const totalSpent = parseFloat($summaryRow.find('th:eq(2)').text().replace('$', '').replace(',', '')) || 0;
        const totalRemaining = newBudget - totalSpent;
        const percentSpent = newBudget > 0 ? Math.min(100, Math.round((totalSpent / newBudget) * 100)) : 0;
        
        $summaryRow.find('th:eq(1)').text(`$${newBudget.toFixed(2)}`);
        $summaryRow.find('th:eq(3)').text(`$${totalRemaining.toFixed(2)}`);
        $summaryRow.find('.progress-bar').css('width', `${percentSpent}%`).attr('aria-valuenow', percentSpent).text(`${percentSpent}%`);
        
        // Update the remaining budget cards
        $('.budget-card-spent .budget-card-subtext span').text(`${percentSpent}% of budget`);
        $('.budget-card-remaining .budget-card-value').text(`$${totalRemaining.toFixed(2)}`);
        $('.budget-card-remaining .progress-bar').css('width', `${percentSpent}%`).attr('aria-valuenow', percentSpent);
    }
    
    // Update charts
    updateCharts();
}

/**
 * Update Charts
 */
function updateCharts() {
    // Get chart instances
    try {
        const charts = Chart.getChart('budgetPieChart');
        if (charts) {
            charts.destroy();
        }
        
        const lineChart = Chart.getChart('spendingLineChart');
        if (lineChart) {
            lineChart.destroy();
        }
        
        // Reinitialize charts with new data
        initBudgetPieChart();
        initSpendingLineChart();
    } catch (e) {
        console.error("Error updating charts:", e);
    }
}

/**
 * Form Validation
 * @param {string} formSelector - jQuery selector for the form
 * @returns {boolean} - Whether the form is valid
 */
function validateForm(formSelector) {
    let isValid = true;
    
    // Check each required field
    $(`${formSelector} [required]`).each(function() {
        if (!$(this).val()) {
            $(this).addClass('is-invalid');
            if ($(this).siblings('.invalid-feedback').length === 0) {
                $(this).after(`<div class="invalid-feedback">This field is required</div>`);
            }
            isValid = false;
        } else {
            $(this).removeClass('is-invalid');
            $(this).siblings('.invalid-feedback').remove();
        }
    });
    
    return isValid;
}

/**
 * Validate Email Format
 * @param {string} email - Email address to validate
 * @returns {boolean} - Whether the email is valid
 */
function validateEmail(email) {
    const re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    return re.test(String(email).toLowerCase());
}

/**
 * Convert RGB to Hex
 * @param {string} rgb - RGB color string (rgb(r, g, b))
 * @returns {string} - Hex color string (#rrggbb)
 */
function rgb2hex(rgb) {
    if (!rgb) return '#1a365d';
    
    try {
        // Check if already hex
        if (rgb.charAt(0) === '#') {
            return rgb;
        }
        
        // Extract RGB values
        const matches = rgb.match(/^rgba?\((\d+),\s*(\d+),\s*(\d+)(?:,\s*\d+\.\d+)?\)$/);
        
        if (matches && matches.length >= 4) {
            // Convert to hex
            const hex = (x) => ("0" + parseInt(x).toString(16)).slice(-2);
            return "#" + hex(matches[1]) + hex(matches[2]) + hex(matches[3]);
        }
        
        return '#1a365d'; // Default color
    } catch (e) {
        console.error("Error converting RGB to hex:", e);
        return '#1a365d'; // Default color
    }
}

// Add document-level event listeners
$(document).on('invalid', '.form-control', function(e) {
    e.preventDefault(); // Prevent browser's default validation UI
    $(this).addClass('is-invalid');
});

$(document).on('input', '.form-control', function() {
    if ($(this).val()) {
        $(this).removeClass('is-invalid');
        $(this).siblings('.invalid-feedback').remove();
    }
});