![iRTES Logo](assets/iRTES-Logo.png)

# CMS iRTES Live Stewarding

The [Live Stewarding Guide](Live_Stewarding_Guide_R02.pdf) describes the
stewarding process from a steward's point of view.

Behind the scenes, I'm using a self-hosted [Baserow.io](https://baserow.io)
installation on a linux VPS at
[irtes-rrc.cmsracing.com](https://irtes-rrc.cmsracing.com). Live Stewards
must be invited to the iRTES group by email to gain access.

The [Live Stewarding Developer Reference](Live%20Stewarding%20Developer%20Reference.pdf) contains some supplemental documentation, including useful Postgres
database queries.

### Live Stewarding Public Description

From a Team Manager point of view, the process is described as follows:

#### Incidents and Live Stewarding
All drivers and Team Managers, please be aware of the following information and procedure for the live stewards. **Incidents must be reported by an involved driver if you want them looked at by the stewards.** Reporting should be done by your Team Manager or delegated to a specific team member, to ensure they are speaking for your team and that we aren't getting duplicate submissions.

The purpose of our steward team is to maintain safe, competitive racing, and that's it. Be good to each other, please.

#### Rules in effect

 - iRTES Sporting Regulations: <https://discord.com/channels/306221952652148737/912131100783046676/1031336663290478612>
 - CMS General Competition Rules (GCR): <https://cmsracing.com/general-competition-rules/>

Please make sure all drivers on your teams have read and understood these!

#### Submitting Incident Review Requests (IRRs)
iRTES IRR Submission Form: <https://cmsracing.com/irtes-irr> *iRTES reports only!*

Lead Steward: Ryan Thompson. DM me with any questions about IRRs, decisions, or stewarding questions about the race.

#### Tracking IRRs

To see the status of IRRs you've submitted (or protests against you), please see the following:
 - IRR Status: <https://cmsracing.com/irtes-irr/list> -- *Use this to check on the review status of IRRs your team has submitted.*
 - IRR Decisions: <https://cmsracing.com/irtes-irr/decisions> -- *Teams use this to check decisions of IRRs, or IRRs you were protested in.*

The `cmsracing.com` permalinks above are done with redirects.

---

## Master registration sheet tool

The [irtes_reg_to_baserow.pl](irtes_reg_to_baserow.pl) script turns the
Master Registration List Excel spreadsheet into comma separated value (CSV)
files. Synopsis:

```
ryan$ ./irtes_reg_to_baserow.pl '/path/to/MASTER_iRTES 2023 Registration.xlsx'
ryan$ ls -1 *.csv
drivers.csv
teams.csv
```

At the start of the season, starting with empty tables, the `Import File`
option in Baserow can import the CSV directly.

Before each subsequent race, export and compare (with `diff(1)`) to the
previous exports to see if there are any changes. Unfortunately, baserow
does not support importing of table relationships, so I must update by hand
after the initial import, but there aren't many changes, so it's not bad.

The [sample_data](sample_data) directory contains both a copy of the Master
Registration List, and the script output. This will not be updated, so please
do treat it as a sample only.

## Author/Copyright

&copy; Ryan Thompson <i@ry.ca>
