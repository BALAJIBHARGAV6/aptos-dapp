
module EduChain::EduChain {
    use std::string::{String, utf8};
    use std::signer;
    use aptos_framework::event;
    use aptos_framework::account;

    /// Error codes
    const E_CERTIFICATE_NOT_FOUND: u64 = 1;

    struct Certificate has key, store {
        student_name: String,
        course: String,
        grade: String,
        year: u64,
        issuer: address,
        certificate_hash: String,
    }

    struct CertificateIssuedEvent has drop, store {
        student_name: String,
        course: String,
        issuer: address,
        certificate_hash: String,
    }

    struct ModuleData has key {
        certificate_issued_events: event::EventHandle<CertificateIssuedEvent>,
    }

    fun init_module(sender: &signer) {
        move_to(sender, ModuleData {
            certificate_issued_events: account::new_event_handle<CertificateIssuedEvent>(sender),
        });
    }

    public entry fun issue_certificate(
        issuer: &signer,
        student_name: String,
        course: String,
        grade: String,
        year: u64,
        certificate_hash: String,
    ) acquires ModuleData {
        let issuer_address = signer::address_of(issuer);

        let certificate = Certificate {
            student_name,
            course,
            grade,
            year,
            issuer: issuer_address,
            certificate_hash: certificate_hash,
        };

        move_to(issuer, certificate);

        let module_data = borrow_global_mut<ModuleData>(@EduChain);
        event::emit_event<CertificateIssuedEvent>(
            &mut module_data.certificate_issued_events,
            CertificateIssuedEvent {
                student_name: certificate.student_name,
                course: certificate.course,
                issuer: certificate.issuer,
                certificate_hash: certificate.certificate_hash,
            }
        );
    }

    public fun get_certificate(
        certificate_owner_address: address,
    ): (String, String, String, u64, address, String) acquires Certificate {
        let certificate_ref = borrow_global<Certificate>(certificate_owner_address);
        (
            certificate_ref.student_name,
            certificate_ref.course,
            certificate_ref.grade,
            certificate_ref.year,
            certificate_ref.issuer,
            certificate_ref.certificate_hash,
        )
    }
}
