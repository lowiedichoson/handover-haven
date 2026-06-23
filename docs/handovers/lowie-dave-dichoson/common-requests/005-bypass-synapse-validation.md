# Bypass Synapse Validation

## Who Asks

| | |
|---|---|
| **Requested by** | TCSG |
| **How they ask** | Email, Sapphire Ticket, Walk-up |
| **Frequency** | Ad-hoc |

## What It Is

Synapse is the system that transfers CPR entries created from Eterminal to Navision for the Accounting department to post journal entries.

## When This Request Happens

- TCSG was unable to ***upload or transfer CPR entries*** to Navision due to a small variance between the Debit and Credit amounts.

## Prerequisites

- Remote access to TCSG's laptop
- Knowledge about inspecting elements in the browser
- ***Documented agreement*** between TCSG and the Accounting department confirming that Synapse's validation may be bypassed when CPR journal entries fail to upload due to Debit and Credit amounts not offsetting to 0.

## Steps

### 1. On TCSG's laptop, right-click on the Synapse screen and select `Inspect`

### 2. In the Elements tab, look for the code block below.

```html
<div data-bind="visible: (debit() + credit() == 0) && (debit() != 0 && credit() != 0)" style="margin-top: 20px;">
    <div>
        <button data-bind="click: upload" class="button-generate"><span class="bold" style="font-size: 17px;">U P L O A D</span></button>
    </div>
    <div style="margin-top: 5px;">
        <asp:Button CssClass="button-export" ID="bt_export" runat="server" Text="EXPORT" />
    </div>
</div>
```

### 3. Modify the `data-bind` property to anything you like so that the upload button becomes visible.

For example, change the `data-bind` to always return `true`:

```html
data-bind="visible: true"
```

### 4. Let the TCSG employee upload the entries using the button.

---
*Last updated: June 2026*
