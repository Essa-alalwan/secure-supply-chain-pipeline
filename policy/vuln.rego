package main

import future.keywords.in

deny[msg] {
    some vuln in input.matches
    vuln.vulnerability.severity == "Critical"
    vuln.vulnerability.fix.state == "fixed"
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
    msg := sprintf("HIGH fixable vulnerability: %s in %s (fix available: %s)", [
        vuln.vulnerability.id,
        vuln.artifact.name,
        vuln.vulnerability.fix.versions[0],
    ])
}