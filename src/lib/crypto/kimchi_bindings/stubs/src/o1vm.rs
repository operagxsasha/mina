use crate::arkworks::{CamlFp, CamlGVesta};
use kimchi::circuits::domains::EvaluationDomains;
use kimchi_msm::expr::E;
use mina_curves::pasta::{Fp, Vesta, VestaParameters};
use mina_poseidon::{
    constants::PlonkSpongeConstantsKimchi,
    sponge::{DefaultFqSponge, DefaultFrSponge},
};
use o1vm::{
    interpreters::mips::constraints as mips_constraints,
    pickles::{proof, prover},
};
use poly_commitment::{ipa::SRS, SRS as _};

pub const DOMAIN_SIZE: usize = 1 << 15;

#[ocaml_gen::func]
#[ocaml::func]
pub fn caml_o1vm_proof_create(
    inputs: proof::caml::CamlProofInputs<CamlFp>,
) -> Result<proof::caml::CamlProof<CamlGVesta, CamlFp>, prover::ProverError>
where {
    // TODO use static values
    let constraints: Vec<E<Fp>> = mips_constraints::make_constraints::<Fp>();
    let domain_fp: EvaluationDomains<Fp> = EvaluationDomains::create(DOMAIN_SIZE).unwrap();
    let srs: SRS<Vesta> = {
        let srs = SRS::create(DOMAIN_SIZE);
        srs.get_lagrange_basis(domain_fp.d1);
        srs
    };

    let inputs = inputs.into();
    let mut rng = rand::thread_rng();
    let proof = prover::prove::<
        Vesta,
        DefaultFqSponge<VestaParameters, PlonkSpongeConstantsKimchi>,
        DefaultFrSponge<Fp, PlonkSpongeConstantsKimchi>,
        _,
    >(domain_fp, &srs, inputs, &constraints, &mut rng)?;
    Ok(proof.into())
}
