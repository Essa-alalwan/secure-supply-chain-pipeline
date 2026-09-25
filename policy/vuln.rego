package main

import future.keywords.in

exceptions := data.exceptions.exceptions

is_excepted(vuln) {
    some ex in exceptions
    ex.cve == vuln.vulnerability.id
    ex.package == vuln.artifact.name
    time.parse_rfc3339_ns(ex.expires) > time.now_ns()
}

deny[msg] {
    some vuln in input.matches
    vuln.vulnerability.severity == "Critical"
    vuln.vulnerability.fix.state == "fixed"
    not is_excepted(vuln)
    msg := sprintf("CRITICAL fixable vulnerability: %s in %s (fix available: %s)", [
        vuln.vulnerability.id,
        vuln.artifact.name,
        vuln.vulnerability.fix.versions[0],
    ])
}

deny[msg] {
    some vuln in input.matches
    vuln.vulnerability.severity == "High"
    vuln.vulnerability.fix.state == "fixed"
    not is_excepted(vuln)
    msg := sprintf("HIGH fixable vulnerability: %s in %s (fix available: %s)", [
        vuln.vulnerability.id,
        vuln.artifact.name,
        vuln.vulnerability.fix.versions[0],
    ])
}

warn[msg] {
    some vuln in input.matches
    is_excepted(vuln)
    msg := sprintf("EXCEPTION IN USE: %s in %s is accepted (see policy/exceptions.json)", [
        vuln.vulnerability.id,
        vuln.artifact.name,
    ])
}