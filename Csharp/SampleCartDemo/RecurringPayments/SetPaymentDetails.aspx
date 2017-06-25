﻿<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SetPaymentDetails.aspx.cs" Inherits="SampleCartDemo.RecurringPayments.SetPaymentDetails" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />

    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.2/css/bootstrap.min.css" />
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.2/css/bootstrap-theme.min.css" />
    <link rel="stylesheet" href="//cdnjs.cloudflare.com/ajax/libs/highlight.js/8.5/styles/default.min.css" />

    <script type="text/javascript" src="https://code.jquery.com/jquery-1.11.2.min.js"></script>
    <script type="text/javascript" src="//maxcdn.bootstrapcdn.com/bootstrap/3.3.2/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="https://code.jquery.com/ui/1.11.4/jquery-ui.min.js"></script>

    <style>
        body {
            padding-top: 40px;
            padding-bottom: 50px;
        }

        .lpa-sdk {
            padding: 40px 15px;
            text-align: center;
        }

        .input-group {
            margin-bottom: 10px;
        }

        #go-home {
            cursor: pointer;
        }

        pre code {
            overflow: scroll;
            word-wrap: normal;
            white-space: pre;
        }

        .jumbotroncolor {
            background: rgba(0, 153, 153, 0.1);
        }

        .jumbotroncodecolor {
            background: rgba(255, 204, 153, 0.4);
        }
    </style>

    <script type='text/javascript'>
        $(document).ready(function () {
            $('.start_over').on('click', function () {
                amazon.Login.logout();
                document.cookie = "amazon_Login_accessToken=; expires=Thu, 01 Jan 1970 00:00:00 GMT";
                window.location = 'index.aspx';
            });
        });
    </script>

    <script type='text/javascript'>
        window.onAmazonLoginReady = function () {
            amazon.Login.setClientId('<%=ConfigurationManager.AppSettings["lwa_client_id"]%>');
            amazon.Login.setUseCookie(true);
        };
    </script>
    <script type='text/javascript' src='https://static-na.payments-amazon.com/OffAmazonPayments/us/sandbox/js/Widgets.js'></script>

</head>
<body>
    <form id="recurringpayments_setdetails" runat="server">

        <div>
            <div class="container">

                <nav class="navbar navbar-default">
                    <div class="container-fluid">
                        <div class="navbar-header">
                            <a class="navbar-brand start_over" href="index.aspx">Amazon Pay C# SDK Recurring Payment</a>
                        </div>
                        <div id="navbar" class="navbar-collapse collapse">
                            <ul class="nav navbar-nav navbar-right">
                                <li><a class="start_over" href="index.aspx">Start Over</a></li>
                            </ul>
                        </div>
                    </div>
                </nav>
                <div class="jumbotron jumbotroncolor" style="padding-top: 25px;" id="api-content">
                    <div id="section-content">

                        <h2>Select Shipping and Payment Method</h2>
                        <p style="margin-top: 20px;">
                            Select your billing address and payment method 
    from the widgets below.
                        </p>
                        <p>
                            Notice in the URL above there are several parameters available. 
    The 'access_token' should be saved in order to obtain address line one and 
    two of the shipping address associated with the payment method.
                        </p>
                        <p>
                            <pre><textarea runat="server" id="access_token_text" class="form-control" readonly="readonly" rows="4"></textarea></pre>
                        </p>
                        <p>
                            This is known as the address consent token. It is passed to the <em>GetBillingAgreementDetails</em> API 
    call to retrieve information about the billing agreement Id that is generated 
    by the widgets.
                        </p>
                        <p>
                            Amazon Billing Agreement ID is shown below. This was generated when the Address Book Widget loaded - onBillingAgreementCreate function.
                        <pre><textarea runat="server" id="amazon_billing_agreement_id" class="form-control" readonly="readonly" rows="1"></textarea></pre>
                        </p>
                        <p>
                            If you see a error message in the widgets you will need to 
    start over. This usually indicates that your session has expired. If the problem 
    persists please contact developer support.
                        </p>

                        <div class="text-center" style="margin-top: 40px;">
                            <div id="addressBookWidgetDiv" style="width: 320px; height: 250px; display: inline-block;"></div>
                            <div id="walletWidgetDiv" style="width: 320px; height: 250px; display: inline-block;"></div>
                            <div id="consentWidgetDiv" style="width: 320px; height: 250px; display: inline-block;"></div>
                            <div style="clear: both;"></div>
                            <div class="form-group">
                                <div class="col-md-10">
                                    <asp:Button ID="place_order" class="btn btn-success" runat="server" Text="Place Order" OnClick="PlaceOrder" />
                                </div>
                            </div>
                            <div id="ajax_loader" style="display: none;">
                                <img src="../images/ajax-loader.gif" />
                            </div>
                        </div>
                        <script type="text/javascript">
                            $('#place_order').prop('disabled', true);
                            var billingAgreementId;
                            var access_token;
                            new OffAmazonPayments.Widgets.AddressBook({
                                sellerId: '<%=ConfigurationManager.AppSettings["merchant_id"]%>',
                                agreementType: 'BillingAgreement',
                                onReady: function (billingAgreement) {
                                    billingAgreementId = billingAgreement.getAmazonBillingAgreementId();
                                    var access_token = $('#access_token_text').val();
                                    $("#amazon_billing_agreement_id").html(billingAgreementId);
                                    get_details(billingAgreementId, access_token);

                                    // render the consent and payment method widgets once the 
                                    // address book has loaded
                                    new OffAmazonPayments.Widgets.Consent({
                                        sellerId: '<%=ConfigurationManager.AppSettings["merchant_id"]%>',
                                        // amazonBillingAgreementId obtained from the Amazon Address Book widget.
                                        amazonBillingAgreementId: billingAgreementId,
                                        design: {
                                            designMode: 'responsive'
                                        },
                                        onReady: function (billingAgreementConsentStatus) {
                                            // Called after widget renders
                                            // getConsentStatus returns true or false
                                            // true Ð checkbox is selected
                                            // false Ð checkbox is unselected - default
                                        },
                                        onConsent: function (billingAgreementConsentStatus) {
                                            buyerBillingAgreementConsentStatus = billingAgreementConsentStatus.getConsentStatus();

                                            if (buyerBillingAgreementConsentStatus == 'true') {
                                                $('#place_order').prop('disabled', false);
                                            } else {
                                                $('#place_order').prop('disabled', true);
                                            }

                                            get_details(billingAgreementId, access_token);
                                            // getConsentStatus returns true or false
                                            // true Ð checkbox is selected Ð buyer has consented
                                            // false Ð checkbox is unselected Ð buyer has not consented

                                            // Replace this code with the action that you want to perform
                                            // after the consent checkbox is selected/unselected.
                                        },
                                        onError: function (error) {
                                            // your error handling code
                                        }
                                    }).bind("consentWidgetDiv");

                                    new OffAmazonPayments.Widgets.Wallet({
                                        sellerId: '<%=ConfigurationManager.AppSettings["merchant_id"]%>',
                                        amazonBillingAgreementId: billingAgreementId,
                                        onPaymentSelect: function (orderReference) {
                                            get_details(billingAgreementId, access_token);
                                        },
                                        design: {
                                            designMode: 'responsive'
                                        },
                                        onError: function (error) {
                                            // your error handling code
                                        }
                                    }).bind("walletWidgetDiv");
                                },
                                onAddressSelect: function (orderReference) {
                                    get_details(billingAgreementId, access_token);
                                },
                                design: {
                                    designMode: 'responsive'
                                },
                                onError: function (error) {
                                    // your error handling code
                                }
                            }).bind("addressBookWidgetDiv");

                            function get_details(billingAgreementId, access_token) {
                                $.ajax({
                                    type: "POST",
                                    url: "SetPaymentDetails.aspx/MakeApiCallAndReturnJsonResponse",
                                    contentType: "application/json",
                                    data: JSON.stringify({
                                        amazonBillingAgreementId: billingAgreementId,
                                        amount: "19.95",
                                        addressConsentToken: ""
                                    }),
                                    dataType: "json",
                                    cache: false,
                                    success: function (data) {

                                        $.each(data.d, function (key, value) {
                                            if (key == "getBillingAgreementDetailsResponse") {
                                                $("#get_details_response").html(value);
                                            }
                                            else if (key == "setBillingAgreementDetailsResponse") {
                                                $("#setBillingAgreementDetailsResponse").html(value);
                                            }
                                        });
                                    }
                                });
                            }
                        </script>

                    </div>
                </div>
                <div class="jumbotron jumbotroncodecolor" style="padding-top: 25px;" id="api-calls">


                    <p>This is the live response from the Set Billing Agreement Details API call.</p>
                    <pre runat="server" id="setBillingAgreementDetailsResponse"><div class="text-center"><img src="../images/ajax-loader.gif" /></div></pre>
                    <br />
                    <br />
                    <p>This is the live response from the Get Billing Agreement Details API call.</p>
                    <pre runat="server" id="get_details_response"><div class="text-center"><img src="../images/ajax-loader.gif" /></div></pre>

                </div>

            </div>
        </div>
    </form>
</body>
</html>
