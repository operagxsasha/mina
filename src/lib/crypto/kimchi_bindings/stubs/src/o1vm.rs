use crate::{
    arkworks::{CamlFp, CamlGVesta},
    field_vector::fp::CamlFpVector,
    pasta_fp_plonk_index::{CamlPastaFpPlonkIndex, CamlPastaFpPlonkIndexPtr},
    pasta_fp_plonk_verifier_index::CamlPastaFpPlonkVerifierIndex,
    srs::fp::CamlFpSrs,
    WithLagrangeBasis,
};
use ark_ec::AffineRepr;
use ark_ff::One;
use array_init::array_init;
use groupmap::GroupMap;
use kimchi::verifier::verify;
use kimchi::{
    circuits::lookup::runtime_tables::{caml::CamlRuntimeTable, RuntimeTable},
    prover_index::ProverIndex,
};
use kimchi::{circuits::polynomial::COLUMNS, verifier::batch_verify};
use kimchi::{
    proof::{
        PointEvaluations, ProofEvaluations, ProverCommitments, ProverProof, RecursionChallenge,
    },
    verifier::Context,
};
use kimchi::{prover::caml::CamlProofWithPublic, verifier_index::VerifierIndex};
use mina_curves::pasta::{Fp, Fq, Pallas, Vesta, VestaParameters};
use mina_poseidon::{
    constants::PlonkSpongeConstantsKimchi,
    sponge::{DefaultFqSponge, DefaultFrSponge},
};
use o1vm::prover;
use poly_commitment::commitment::{CommitmentCurve, PolyComm};
use poly_commitment::ipa::OpeningProof;
use std::array;
use std::convert::TryInto;

type EFqSponge = DefaultFqSponge<VestaParameters, PlonkSpongeConstantsKimchi>;
type EFrSponge = DefaultFrSponge<Fp, PlonkSpongeConstantsKimchi>;

#[ocaml_gen::func]
#[ocaml::func]
pub fn caml_o1vm_proof_create(
    index: CamlPastaFpPlonkIndexPtr<'static>,
    witness: Vec<CamlFpVector>,
    runtime_tables: Vec<CamlRuntimeTable<CamlFp>>,
    prev_challenges: Vec<CamlFp>,
    prev_sgs: Vec<CamlGVesta>,
) -> Result<CamlProofWithPublic<CamlGVesta, CamlFp>, ocaml::Error> {
    #[ocaml_gen::func]
    #[ocaml::func]
    pub fn caml_o1vm_proof_create(
        domain: CamlEvaluationDomains<CamlFp>,
        srs: CamlFpSrs,
        inputs: CamlProofInputs<CamlFp>,
        constraints: &[E<CamlFp>],
    ) -> Result<CamlProof<CamlFp>, ProverError>
where {
        let domain = domain.into();
        let srs = srs.into();
        let inputs = inputs.into();
        let constraints = constraints.into();
        let proof = prover::create_proof(domain, srs, inputs, constraints)?;
        Ok(proof.into())
    }
}
