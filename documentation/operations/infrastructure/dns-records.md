# DNS

## DNS management

DNS is managed via AWS's Route53, through Infrastructure as Code using Terraform.

## Zones

Teaching vacancies has two Route53 hosted zones:
- teaching-jobs.service.gov.uk
- teaching-vacancies.service.gov.uk

We create DNS records in both zones, but treat `teaching-vacancies.service.gov.uk` as the primary

## Zone creation

The code in `terraform/common` manages the zones.

## Record types

The following record types are in use:

### [A record](https://www.cloudflare.com/learning/dns/dns-records/dns-a-record/)
> The `A` stands for `address` and this is the most fundamental type of DNS record: it indicates the IP address of a given domain. For example, if you pull the DNS records of cloudflare.com, the A record currently returns an IP address of: 104.17.210.9.
>
> A records only hold IPv4 addresses. If a website has an IPv6 address, it will instead use an ‘AAAA’ record.

In a Teaching Vacancies hosted zone, [this is set](https://toolbox.googleapps.com/apps/dig/#A/teaching-vacancies.service.gov.uk) as an Alias to the Cloudfront distribution, so responds with multiple IP addresses, e.g.:
```
teaching-vacancies.service.gov.uk. 59 IN A 13.33.242.3
teaching-vacancies.service.gov.uk. 59 IN A 13.33.242.81
teaching-vacancies.service.gov.uk. 59 IN A 13.33.242.97
teaching-vacancies.service.gov.uk. 59 IN A 13.33.242.96
```

### [CNAME record](https://www.cloudflare.com/learning/dns/dns-records/dns-cname-record/)
> The `canonical name` (CNAME) record is used in lieu of an A record, when a domain or subdomain is an alias of another domain. All CNAME records must point to a domain, never to an IP address. Imagine a scavenger hunt where each clue points to another clue, and the final clue points to the treasure. A domain with a CNAME record is like a clue that can point you to another clue (another domain with a CNAME record) or to the treasure (a domain with an A record).

In a Teaching Vacancies hosted zone, CNAMEs are used for three purposes:
- verification of Amazon Certificate Manager certificates
- verification of bing searches
- [alias to the Cloudfront distribution](https://toolbox.googleapps.com/apps/dig/#CNAME/www.teaching-vacancies.service.gov.uk)

### [CAA record](https://letsencrypt.org/docs/caa/)
> CAA is a type of DNS record that allows site owners to specify which Certificate Authorities (CAs) are allowed to issue certificates containing their domain names. It was standardized in 2013 by RFC 6844 to allow a CA “reduce the risk of unintended certificate mis-issue.” By default, every public CA is allowed to issue certificates for any domain name in the public DNS, provided they validate control of that domain name. That means that if there’s a bug in any one of the many public CAs’ validation processes, every domain name is potentially affected. CAA provides a way for domain holders to reduce that risk.

In a Teaching Vacancies hosted zone, [this is set](https://toolbox.googleapps.com/apps/dig/#CAA/teaching-vacancies.service.gov.uk) to `0 issue "amazon.com"` with a TTL of 300 seconds

### [NS records](https://www.cloudflare.com/learning/dns/dns-records/dns-ns-record/) and [SOA record](https://www.cloudflare.com/learning/dns/dns-records/dns-soa-record/)
The [Route 53 developer guide](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/SOA-NSrecords.html) has:
> For each public hosted zone that you create, Amazon Route 53 automatically creates a name server (NS) record and a start of authority (SOA) record. You rarely need to change these records.

These are used for delegation, so are set in the parent zone for `service.gov.uk` by GDS.

### [TXT records](https://www.cloudflare.com/learning/dns/dns-records/dns-txt-record/)
> The DNS `text` (TXT) record lets a domain administrator enter text into the Domain Name System (DNS). The TXT record was originally intended as a place for human-readable notes. However, now it is also possible to put some machine-readable data into TXT records. One domain can have many TXT records.
>
> Today, two of the most important uses for DNS TXT records are email spam prevention and domain ownership verification, although TXT records were not designed for these uses originally.

In a Teaching Vacancies hosted zone, we set TXT records for DMARC and SPF purposes to indicate *that this domain does not send any email*

### DMARC

```
"v=DMARC1; p=reject; sp=reject; rua=mailto:dmarc-rua@dmarc.service.gov.uk; ruf=mailto:dmarc-ruf@dmarc.service.gov.uk"
```

Deriving from [Setting up DMARC](https://www.gov.uk/government/publications/email-security-standards/domain-based-message-authentication-reporting-and-conformance-dmarc) and the [DMARC specifications](https://dmarc.org/resources/specification/)

This tells anyone receiving email from you that:

- you have a DMARC policy (v=DMARC1)
- any messages that fail DMARC checks should be rejected (p=reject)
- any messages that fail DMARC checks *for this subdomain* should be rejected (sp=reject)
- they should send aggregate reports of email received back to a specific address (rua=mailto:dmarc-rua@dmarc.service.gov.uk)
- they should send forensic reports of email received back to a specific address (ruf=mailto:dmarc-ruf@dmarc.service.gov.uk)

### SPF

[Sender Policy Framework](https://www.gov.uk/government/publications/email-security-standards/sender-policy-framework-spf)
> Sender Policy Framework (SPF) lets you publish a DNS record of all the domains or IP addresses you use to send email. Receiving email services check the record and know to treat email from anywhere else as spam.
>
> You can include more than one sending service in your SPF record. For example, your corporate email service and an email marketing service.

[Set up Government email services securely](https://www.gov.uk/guidance/set-up-government-email-services-securely#authenticate-email) covers this in more detail:

> Implement Sender Policy Framework (SPF) by:
>
> -publishing public DNS records for SPF, including all systems that send email, using a minimum soft fail (~all) qualifier

From [this SPF syntax table](https://dmarcian.com/spf-syntax-table/) we see
```
“v=spf1 ~all”
```
> The domain sends no mail at all

Note from this discussion on [What is the difference between SPF ~all and -all?](https://dmarcian.com/what-is-the-difference-between-spf-all-and-all/)

>By adding a prefix of “~” or “-“, the meaning of the mechanism is changed to be:
>
> - “softfail” in the case of “~”
> - “fail” in the case of “-“

## Record creation

The [Route 53 developer guide](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/SOA-NSrecords.html) has:
> For each public hosted zone that you create, Amazon Route 53 automatically creates a name server (NS) record and a start of authority (SOA) record. You rarely need to change these records.

Records are created in `terraform/common`:
- TXT records for DMARC, SPF, search engine validation
- CAA record

Records are created in `terraform/app` by two different modules:

- `terraform/app/modules/certificates` creates:
    - CNAME records to `acm-validations.aws.`

- `terraform/app/modules/cloudfront` creates:
    - CNAME records pointing to a Cloudfront distribution, for `www.` and `staging.`
    - Alias A records pointing to the Cloudfront distribution, for the `naked` (root) domain

## Tools

Google's [G Suite Toolbox Dig](https://toolbox.googleapps.com/apps/dig/#A/) is excellent for checking the DNS records listed above.
