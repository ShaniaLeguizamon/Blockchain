// test/DiplomaNFT.js
import { ethers } from "hardhat";
import { expect } from "chai";

describe("DiplomaNFT", function () {
    let diplomaNFT;
    let owner;
    let student;
    let verifier;

    // Antes de cada prueba, despliega un nuevo contrato.
    beforeEach(async function () {
        [owner, student, verifier] = await ethers.getSigners();

        const DiplomaNFT = await ethers.getContractFactory("DiplomaNFT");
        diplomaNFT = await DiplomaNFT.deploy();
    });

    it("Debe permitir al propietario emitir un diploma", async function () {
        // La universidad (propietario) emite un diploma para el estudiante.
        await diplomaNFT.mintDiploma(
            student.address,
            "ipfs://hashdelmetadato",
            "Juan Perez",
            "Ingeniería de Software",
            "2025-12-15"
        );

        // Verifica que el estudiante es ahora el dueño del token 0.
        expect(await diplomaNFT.ownerOf(0)).to.equal(student.address);
    });

    it("Debe verificar que el diploma es válido", async function () {
        // Emite el diploma primero.
        await diplomaNFT.mintDiploma(student.address, "ipfs://...", "Juan Perez", "Ingeniería de Software", "2025-12-15");

        // El verificador (cualquier persona) comprueba su validez.
        expect(await diplomaNFT.isDiplomaValid(0)).to.equal(true);
    });

    it("Debe permitir al propietario revocar un diploma", async function () {
        // Emite el diploma primero.
        await diplomaNFT.mintDiploma(student.address, "ipfs://...", "Juan Perez", "Ingeniería de Software", "2025-12-15");

        // El propietario (la universidad) revoca el diploma.
        await diplomaNFT.revokeDiploma(0);

        // El verificador comprueba que ahora no es válido.
        expect(await diplomaNFT.isDiplomaValid(0)).to.equal(false);
    });
});