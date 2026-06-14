import '../models/chapter.dart';

final List<Chapter> allChapters = [
  Chapter(
    id: 1,
    name: 'Electric Charges and Fields',
    subject: 'Physics',
    pages: 30,
    weightage: 16,
    keyFormulas:
        'Coulomb\'s Law: F = k|q1q2|/r²\nElectric Field: E = F/q\n'
        'Electric Flux: Φ = E·A\nGauss\'s Law: ∮E·dA = Q/ε₀\n'
        'Linear charge density: λ = q/l\nSurface charge density: σ = q/A',
    detailedNotes:
        'Electric charge is a fundamental property of matter. Like charges repel, unlike charges attract.\n'
        'Conductors allow charge flow; insulators do not. Charging by induction redistributes charge without contact.\n'
        'Coulomb\'s law gives force between two point charges. Superposition principle applies.\n'
        'Electric field lines start at positive charges and end at negative charges.\n'
        'Electric dipole: two equal opposite charges separated by small distance. Dipole moment p = q·d.\n'
        'Gauss\'s law relates flux through closed surface to enclosed charge.',
    examples:
        'Q1: Two charges 2μC and -4μC are placed 0.1m apart. Find force on 2μC charge.\n'
        'Solution: F = 9×10⁹ × |2×10⁻⁶ × (-4)×10⁻⁶| / 0.1² = 7.2 N (attractive)\n\n'
        'Q2: Find electric field at midpoint of dipole with ±5μC charges 2cm apart.\n'
        'Solution: E = 2kq/(d/2)² = 2×9×10⁹×5×10⁻⁶/(0.01)² = 9×10⁸ N/C',
    practiceProblems:
        '1. Two point charges +5μC and -5μC are placed 0.2m apart. Calculate electric field at the midpoint.\n'
        '2. A charge of 10μC is placed in uniform electric field 500 N/C. Find force experienced.\n'
        '3. Find electric flux through sphere of radius 0.1m with 2μC charge at centre.\n'
        '4. An electric dipole of moment 2×10⁻⁸ C-m is aligned at 60° with uniform field 10⁵ N/C. Find torque.',
  ),
  Chapter(
    id: 2,
    name: 'Electrostatic Potential and Capacitance',
    subject: 'Physics',
    pages: 28,
    weightage: 16,
    keyFormulas:
        'Electric Potential: V = kq/r\nPotential Energy: U = kq1q2/r\n'
        'Capacitance: C = Q/V\nParallel Plate: C = ε₀A/d\n'
        'Energy stored: U = ½CV² = ½QV = Q²/2C\nSeries: 1/Ceq = 1/C₁ + 1/C₂\nParallel: Ceq = C₁ + C₂',
    detailedNotes:
        'Electric potential is work done per unit charge to bring from infinity.\n'
        'Equipotential surfaces have same potential; no work done moving charge on them.\n'
        'Potential due to dipole: V = kpcosθ/r²\n'
        'Capacitor stores electrical energy. Dielectrics increase capacitance by factor K.\n'
        'Van de Graaff generator builds high potential using belt and corona discharge.',
    examples:
        'Q1: Find potential at point 0.3m from 4μC charge.\n'
        'Solution: V = 9×10⁹ × 4×10⁻⁶/0.3 = 1.2×10⁵ V\n\n'
        'Q2: 10μF capacitor charged to 100V. Find energy stored.\nSolution: U = ½×10×10⁻⁶×100² = 0.05 J',
    practiceProblems:
        '1. Calculate potential at midpoint of line joining +2μC and -2μC charges 0.1m apart.\n'
        '2. A 5μF capacitor is connected to 12V battery. Find charge and energy stored.\n'
        '3. Three capacitors 2μF, 3μF, 5μF in series. Find equivalent capacitance.\n'
        '4. Dielectric of K=4 inserted in 10μF capacitor. Find new capacitance.',
  ),
  Chapter(
    id: 3,
    name: 'Current Electricity',
    subject: 'Physics',
    pages: 26,
    weightage: 15,
    keyFormulas:
        'Ohm\'s Law: V = IR\nResistance: R = ρL/A\n'
        'Power: P = VI = I²R = V²/R\nConductance: G = 1/R\n'
        'Kirchhoff\'s Voltage Law: ΣV = 0\nKirchhoff\'s Current Law: ΣI = 0\n'
        'Wheatstone Bridge: R₁/R₂ = R₃/R₄',
    detailedNotes:
        'Electric current: rate of flow of charge I = dq/dt.\n'
        'Drift velocity: vd = eEτ/m. Current I = nAevd.\n'
        'Resistivity depends on temperature: ρ = ρ₀[1+α(T-T₀)].\n'
        'Cells in series increase voltage, in parallel increase current capacity.\n'
        'Meter bridge and potentiometer measure resistance and potential difference.',
    examples:
        'Q1: Wire of length 2m, area 0.5mm², resistance 5Ω. Find resistivity.\n'
        'Solution: ρ = RA/L = 5×0.5×10⁻⁶/2 = 1.25×10⁻⁶ Ωm\n\n'
        'Q2: Find current through 10Ω resistor with 20V battery.\nSolution: I = V/R = 20/10 = 2A',
    practiceProblems:
        '1. A copper wire of length 1m and diameter 0.5mm has resistance 0.04Ω. Find resistivity.\n'
        '2. Three resistors 2Ω, 3Ω, 6Ω in parallel. Find equivalent resistance.\n'
        '3. A 12V battery with internal resistance 0.5Ω connected to 5.5Ω load. Find current.\n'
        '4. In Wheatstone bridge, R₁=2Ω, R₂=3Ω, R₃=4Ω. Find R₄ for balance.',
  ),
  Chapter(
    id: 4,
    name: 'Magnetism and Matter',
    subject: 'Physics',
    pages: 22,
    weightage: 12,
    keyFormulas:
        'Magnetic dipole moment: M = NIA\nTorque on dipole: τ = MBsinθ\n'
        'Magnetic field due to bar magnet: B = μ₀M/(4πr³)×√(1+3cos²θ)\n'
        'Gauss\'s law for magnetism: ∮B·dA = 0\n'
        'Magnetic susceptibility: χm = M/H\nPermeability: μ = μ₀(1+χm)',
    detailedNotes:
        'Bar magnet has north and south poles. Like poles repel, unlike attract.\n'
        'Earth has magnetic field: declination, dip angle, horizontal component.\n'
        'Magnetic materials: diamagnetic (χm negative), paramagnetic (χm small positive), ferromagnetic (χm large).\n'
        'Curie temperature: above which ferromagnetic becomes paramagnetic.\n'
        'Hysteresis loop shows B-H relationship for ferromagnetic materials.',
    examples:
        'Q1: Bar magnet of magnetic moment 2 A·m² placed in 0.5T field at 60°. Find torque.\n'
        'Solution: τ = MBsinθ = 2×0.5×sin60° = 0.866 Nm\n\n'
        'Q2: Find dip angle if horizontal component = vertical component.\nSolution: tanδ = Bv/BH = 1, δ = 45°',
    practiceProblems:
        '1. A bar magnet of length 0.1m has pole strength 10 A-m. Find magnetic moment.\n'
        '2. At a point on equatorial line, magnetic field is 2×10⁻⁵ T. Find field on axial line.\n'
        '3. Find vertical component of earth\'s field if horizontal = 0.3 G and dip = 30°.\n'
        '4. Classify given materials: water, aluminium, iron, copper as dia/para/ferro.',
  ),
  Chapter(
    id: 5,
    name: 'Solutions',
    subject: 'Chemistry',
    pages: 24,
    weightage: 14,
    keyFormulas:
        'Concentration: M = n/V(L), m = n/kg solvent\n'
        'Mole fraction: xA = nA/(nA+nB)\n'
        'Henry\'s Law: p = KH·x\n'
        'Raoult\'s Law: p = p°·x\n'
        'ΔTb = Kb·m\nΔTf = Kf·m\n'
        'π = iCRT',
    detailedNotes:
        'Solution: homogeneous mixture of two or more substances.\n'
        'Solubility of gases increases with pressure (Henry\'s law), decreases with temperature.\n'
        'Ideal solutions obey Raoult\'s law at all concentrations.\n'
        'Colligative properties: vapor pressure lowering, boiling point elevation, freezing point depression, osmotic pressure.\n'
        'Van\'t Hoff factor i accounts for dissociation/association.',
    examples:
        'Q1: 10g glucose in 100g water. Find molality.\nSolution: moles = 10/180 = 0.0556, m = 0.0556/0.1 = 0.556 m\n\n'
        'Q2: BP of 0.1m NaCl solution (Kb=0.512, i=2).\nSolution: ΔTb = 2×0.512×0.1 = 0.1024°C',
    practiceProblems:
        '1. Find molarity of 5.85g NaCl in 500mL solution.\n'
        '2. Calculate freezing point depression for 0.2m glucose solution (Kf=1.86).\n'
        '3. 2g urea in 100g water; BP of pure water = 100°C, Kb=0.512. Find BP.\n'
        '4. Osmotic pressure of 0.1M sucrose at 27°C. (R=0.0821 L·atm/mol·K)',
  ),
  Chapter(
    id: 6,
    name: 'Electrochemistry',
    subject: 'Chemistry',
    pages: 22,
    weightage: 14,
    keyFormulas:
        'Nernst Equation: E = E° - (RT/nF)lnQ\n'
        'Standard EMF: E°cell = E°cathode - E°anode\n'
        'Faraday\'s Law: m = (M×I×t)/(n×F)\n'
        'Conductivity: κ = G×l/A\n'
        'Λm = κ/C\n'
        'ΔG = -nFE',
    detailedNotes:
        'Electrochemical cells convert chemical energy to electrical.\n'
        'Galvanic cell: spontaneous redox reaction produces electricity.\n'
        'Electrolytic cell: electricity drives non-spontaneous reaction.\n'
        'Standard hydrogen electrode: reference electrode with E°=0.\n'
        'Kohlrausch\'s law: Λ°m = λ°+ + λ°-\n'
        'Batteries: primary (non-rechargeable), secondary (rechargeable).',
    examples:
        'Q1: Calculate EMF of Zn-Cu cell (E°Zn=-0.76V, E°Cu=+0.34V).\nSolution: E°cell = 0.34 - (-0.76) = 1.10V\n\n'
        'Q2: Find mass of Cu deposited by 2A for 30 min (M=63.5, n=2).\nSolution: m = (63.5×2×1800)/(2×96500) = 1.185g',
    practiceProblems:
        '1. Calculate EMF of cell: Zn|Zn²⁺(0.1M)||Cu²⁺(1M)|Cu at 25°C.\n'
        '2. How much Al (M=27, n=3) is deposited by 5A for 1 hour?\n'
        '3. Write cell reaction and calculate E°: Ag⁺/Ag = 0.80V, Fe³⁺/Fe²⁺ = 0.77V.\n'
        '4. Calculate ΔG for reaction with E°cell = 1.10V, n=2, F=96500 C/mol.',
  ),
  Chapter(
    id: 7,
    name: 'Chemical Kinetics',
    subject: 'Chemistry',
    pages: 20,
    weightage: 12,
    keyFormulas:
        'Rate = -d[R]/dt = k[R]ⁿ\n'
        'Zero order: [R] = [R]₀ - kt\nFirst order: k = (2.303/t)log([R]₀/[R])\n'
        'Half-life: t½ = 0.693/k (first order)\nt½ = [R]₀/2k (zero order)\n'
        'Arrhenius: k = Ae⁻ᴱᵃ/ᴿᵀ\nln(k₂/k₁) = Ea/R(1/T₁-1/T₂)',
    detailedNotes:
        'Chemical kinetics studies reaction rates and mechanisms.\n'
        'Rate law: experimentally determined. Order ≠ stoichiometry.\n'
        'Molecularity: number of molecules colliding in elementary step.\n'
        'Activation energy: minimum energy for reaction.\n'
        'Catalyst lowers activation energy, increases rate.\n'
        'Temperature: 10°C rise typically doubles rate.',
    examples:
        'Q1: Half-life of first order reaction is 50 min. Find rate constant.\nSolution: k = 0.693/50 = 0.01386 min⁻¹\n\n'
        'Q2: Rate doubles for 10°C rise from 300K to 310K. Find Ea.\nSolution: Ea = 8.314×300×310×ln2/10 = 53594 J/mol',
    practiceProblems:
        '1. For first order reaction, 75% completes in 40 min. Find half-life.\n'
        '2. Zero order reaction: initial conc = 1M, k = 0.05 M/s. Find time for 80% completion.\n'
        '3. Rate triples when T from 300K to 310K. Calculate activation energy.\n'
        '4. Write rate law: 2A + B → products, experimental rates given.',
  ),
  Chapter(
    id: 8,
    name: 'Haloalkanes and Haloarenes',
    subject: 'Chemistry',
    pages: 20,
    weightage: 12,
    keyFormulas:
        'SN1: Rate = k[R-X] (tertiary favoured, carbocation intermediate)\n'
        'SN2: Rate = k[R-X][OH⁻] (primary favoured, inversion)\n'
        'E2 elimination: requires strong base, anti-periplanar\n'
        'Grignard reagent: R-X + Mg → RMgX\n'
        'Wurtz reaction: 2RX + 2Na → R-R + 2NaX',
    detailedNotes:
        'Haloalkanes: halogen attached to sp³ carbon.\n'
        'Haloarenes: halogen attached to aromatic ring.\n'
        'SN1: two steps, racemization. SN2: one step, inversion.\n'
        'Haloarenes less reactive than haloalkanes due to resonance.\n'
        'Electrophilic substitution on haloarenes: ortho/para directing.\n'
        'DDT, freons, chloroform are important halogen compounds.',
    examples:
        'Q1: Identify product: CH₃CH₂Br + NaOH (aq) → ?\nSolution: CH₃CH₂OH (SN2, primary)\n\n'
        'Q2: Which reacts faster in SN1: CH₃CH₂Br or (CH₃)₃CBr?\nSolution: (CH₃)₃CBr (tertiary carbocation stable)',
    practiceProblems:
        '1. Write SN2 mechanism for CH₃Br + OH⁻.\n'
        '2. Why are haloarenes less reactive than haloalkanes?\n'
        '3. Complete: CH₃CH₂CH₂Br + KOH (alc) → ?\n'
        '4. Distinguish between chloroform and carbon tetrachloride.',
  ),
  Chapter(
    id: 9,
    name: 'Aldehydes, Ketones and Carboxylic Acids',
    subject: 'Chemistry',
    pages: 26,
    weightage: 16,
    keyFormulas:
        'Carbonyl: C=O, electrophilic carbon, nucleophilic addition\n'
        'Aldol condensation: 2CH₃CHO → CH₃CH(OH)CH₂CHO\n'
        'Cannizzaro: 2HCHO → CH₃OH + HCOOH (no α-H)\n'
        'Fehling test: RCHO + Cu²⁺ → RCOOH + Cu₂O (red ppt)\n'
        'Tollens test: RCHO + Ag⁺ → RCOOH + Ag (mirror)\n'
        'Haloform reaction: CH₃COR + 3I₂ + 4NaOH → CHI₃ + RCOONa',
    detailedNotes:
        'Aldehydes: carbonyl at end of chain. Ketones: carbonyl in middle.\n'
        'Nucleophilic addition: HCN, NaHSO₃, Grignard reagent add to C=O.\n'
        'Reduction: to alcohols (NaBH₄/LiAlH₄), to hydrocarbons (Clemmensen/Wolff-Kishner).\n'
        'Carboxylic acids: acidic (COOH), form dimers via H-bonding.\n'
        'Decarboxylation: RCOOH → RH + CO₂ (soda lime).\n'
        'Tests: NaHCO₃ gives CO₂ with acids.',
    examples:
        'Q1: Identify product: CH₃CHO + HCN → ?\nSolution: CH₃CH(OH)CN (cyanohydrin)\n\n'
        'Q2: Test to distinguish acetaldehyde and acetone.\nSolution: Fehling test: aldehyde gives red ppt, ketone does not.',
    practiceProblems:
        '1. Complete: CH₃COCH₃ + I₂ + NaOH → ?\n'
        '2. Give product of aldol condensation of propanal.\n'
        '3. How will you convert benzoic acid to benzaldehyde?\n'
        '4. Distinguish between formaldehyde and acetaldehyde using chemical tests.',
  ),
  Chapter(
    id: 10,
    name: 'Coordination Compounds',
    subject: 'Chemistry',
    pages: 24,
    weightage: 14,
    keyFormulas:
        'Werner\'s theory: primary valency = oxidation state, secondary = coordination number\n'
        'IUPAC: ligands in alphabetical order, metal + oxidation state in Roman\n'
        'CFT: d-orbital splitting - octahedral (Δ₀), tetrahedral (Δt)\n'
        'Δ₀ = hc/λ (from absorption spectra)\n'
        'Magnetic moment: μ = √(n(n+2)) BM (n = unpaired electrons)',
    detailedNotes:
        'Coordination compound: central metal ion surrounded by ligands.\n'
        'Ligands: neutral (NH₃, H₂O) or anionic (Cl⁻, CN⁻). Denticity: mono/bi/polydentate.\n'
        'Chelation: polydentate ligand forms ring - more stable.\n'
        'Isomerism: geometrical (cis/trans), optical (d/l), linkage, ionization.\n'
        'Crystal Field Theory: color and magnetic properties explained by d-orbital splitting.\n'
        'Applications: extraction, water purification, medicines.',
    examples:
        'Q1: IUPAC name of [Co(NH₃)₆]Cl₃.\nSolution: Hexaamminecobalt(III) chloride\n\n'
        'Q2: Find magnetic moment of [Fe(CN)₆]⁴⁻ (low spin, d⁶, all paired).\nSolution: μ = 0 BM (no unpaired electrons)',
    practiceProblems:
        '1. Write IUPAC: K₃[Fe(CN)₆]\n'
        '2. Give geometry and magnetic moment of [Ni(CO)₄].\n'
        '3. Why is [Cu(NH₃)₄]²⁺ coloured but [Cu(CN)₄]³⁻ colourless?\n'
        '4. Distinguish between low spin and high spin complexes with example.',
  ),
  Chapter(
    id: 11,
    name: 'Relations and Functions',
    subject: 'Mathematics',
    pages: 22,
    weightage: 12,
    keyFormulas:
        'Reflexive: aRa for all a\nSymmetric: aRb ⇒ bRa\nTransitive: aRb, bRc ⇒ aRc\n'
        'Equivalence: reflexive + symmetric + transitive\n'
        'One-one: f(a) = f(b) ⇒ a = b\nOnto: range = codomain\n'
        'Composition: (f∘g)(x) = f(g(x))\nInverse: f⁻¹(y) = x iff f(x) = y',
    detailedNotes:
        'Relation: subset of A×B. Types: empty, universal, identity, inverse.\n'
        'Function: each input has exactly one output.\n'
        'Domain: set of inputs. Range: set of outputs.\n'
        'Bijective = injective (one-one) + surjective (onto).\n'
        'Binary operations: closure, associative, identity, inverse.',
    examples:
        'Q1: Check if R = {(x,y): y = x+1, x<4} on A={1,2,3} is function.\nSolution: Domain {1,2,3}, values {2,3,4}. Each x maps to exactly one y. Yes.\n\n'
        'Q2: f(x)=2x+1, g(x)=x², find f∘g.\nSolution: f(g(x)) = 2x²+1',
    practiceProblems:
        '1. Show that R = {(a,b): |a-b| is even} is equivalence relation on integers.\n'
        '2. Check if f(x)=x² is one-one and onto for R→R.\n'
        '3. Find fog and gof: f(x)=x+1, g(x)=x³.\n'
        '4. Check if * defined as a*b = ab is binary operation on natural numbers.',
  ),
  Chapter(
    id: 12,
    name: 'Matrices',
    subject: 'Mathematics',
    pages: 20,
    weightage: 12,
    keyFormulas:
        'Addition: (A+B)ij = aij + bij\nMultiplication: (AB)ik = Σaij·bjk\n'
        'Transpose: (A^T)ij = aji\nSymmetric: A^T = A, Skew-symmetric: A^T = -A\n'
        'Inverse: A⁻¹ = adj(A)/|A|\n'
        'Property: (AB)⁻¹ = B⁻¹A⁻¹\n(AB)^T = B^T A^T',
    detailedNotes:
        'Matrix: rectangular array of numbers. Order: m×n.\n'
        'Types: row, column, square, diagonal, scalar, identity, zero.\n'
        'Elementary row operations: swap, multiply, add multiple.\n'
        'Invertible matrix: |A| ≠ 0.\n'
        'System of equations: AX = B ⇒ X = A⁻¹B.\n'
        'Applications: cryptography, computer graphics, economics.',
    examples:
        'Q1: Find AB if A=[[1,2],[3,4]] and B=[[5,6],[7,8]].\nSolution: AB = [[1×5+2×7, 1×6+2×8],[3×5+4×7, 3×6+4×8]] = [[19,22],[43,50]]\n\n'
        'Q2: Find inverse of [[2,3],[1,4]].\nSolution: |A|=5, adj=[[4,-3],[-1,2]], A⁻¹=[[4/5,-3/5],[-1/5,2/5]]',
    practiceProblems:
        '1. Multiply [[1,0,2],[3,-1,4]] by [[2,1],[0,-2],[3,5]].\n'
        '2. Find inverse of [[1,2,3],[0,1,4],[5,6,0]].\n'
        '3. If A=[[1,2],[3,4]], find A² - 5A + 2I.\n'
        '4. Solve: 2x+3y=7, 3x+5y=9 using matrix method.',
  ),
  Chapter(
    id: 13,
    name: 'Continuity and Differentiability',
    subject: 'Mathematics',
    pages: 26,
    weightage: 14,
    keyFormulas:
        'Continuity: lim(x→a) f(x) = f(a)\n'
        'Differentiability: f\'(a) = lim(h→0) [f(a+h)-f(a)]/h\n'
        'Chain rule: dy/dx = dy/du × du/dx\n'
        'Rolle\'s: f(a)=f(b) ⇒ f\'(c)=0 for some c∈(a,b)\n'
        'LMVT: [f(b)-f(a)]/(b-a) = f\'(c) for some c∈(a,b)\n'
        'Log differentiation: lny = lnf(x), differentiate',
    detailedNotes:
        'Continuity: no breaks, jumps, or holes in graph.\n'
        'Types of discontinuity: removable, jump, infinite.\n'
        'Differentiable ⇒ continuous. Converse not true.\n'
        'Derivatives of: inverse trig, implicit, parametric, logarithmic.\n'
        'Second derivative: rate of change of first derivative.\n'
        'Mean Value Theorems: Rolle\'s (special case), Lagrange\'s (general).',
    examples:
        'Q1: Check continuity of f(x)=|x-2| at x=2.\nSolution: LHL=RHL=f(2)=0. Continuous.\n\n'
        'Q2: Find dy/dx if y = x^x.\nSolution: lny = xlnx, (1/y)dy/dx = lnx+1, dy/dx = x^x(lnx+1)',
    practiceProblems:
        '1. Check continuity of f(x)=1/(x-3) at x=3.\n'
        '2. Find dy/dx: y = sin⁻¹(2x/(1+x²)).\n'
        '3. Verify Rolle\'s theorem for f(x)=x²-4x+3 on [1,3].\n'
        '4. Find second derivative: y = e^x sinx.',
  ),
  Chapter(
    id: 14,
    name: 'Integrals',
    subject: 'Mathematics',
    pages: 30,
    weightage: 16,
    keyFormulas:
        '∫xⁿ dx = xⁿ⁺¹/(n+1) + C (n≠-1)\n∫1/x dx = ln|x| + C\n'
        '∫eˣ dx = eˣ + C\n∫sinx dx = -cosx + C\n∫cosx dx = sinx + C\n'
        'Integration by parts: ∫uv dx = u∫v dx - ∫(u\'∫v dx)dx\n'
        'Definite: ∫ᵇₐ f(x)dx = F(b)-F(a)\n'
        'Properties: ∫ᵇₐ f = -∫ᵃᵦ f, ∫ᵇₐ f = ∫ᶜₐ f + ∫ᵇₓ f',
    detailedNotes:
        'Integration: reverse of differentiation (antiderivative).\n'
        'Methods: substitution, partial fractions, integration by parts.\n'
        'Definite integrals: limits of integration, area interpretation.\n'
        'Properties: even/odd functions, periodic functions, king\'s property.\n'
        'Improper integrals: infinite limits or discontinuous integrand.\n'
        'Application: area between curves, volume of revolution.',
    examples:
        'Q1: Find ∫(3x²+2x+1)dx.\nSolution: x³ + x² + x + C\n\n'
        'Q2: Evaluate ∫₀¹ x²eˣ dx.\nSolution: Using parts, u=x², dv=eˣdx. = [x²eˣ]₀¹ - 2∫₀¹ xeˣdx\n= e - 2([xeˣ]₀¹ - ∫₀¹ eˣdx) = e - 2(e - (e-1)) = e - 2 = 0.718',
    practiceProblems:
        '1. Integrate ∫(4x³-3x²+2x-1)dx.\n'
        '2. Evaluate ∫₀ᴾ sinx dx.\n'
        '3. Find ∫x²cosx dx using integration by parts.\n'
        '4. Find area bounded by y=x² and y=x.',
  ),
  Chapter(
    id: 15,
    name: 'Three Dimensional Geometry',
    subject: 'Mathematics',
    pages: 22,
    weightage: 12,
    keyFormulas:
        'Direction cosines: l²+m²+n²=1\n'
        'Distance between points: d = √((x₂-x₁)²+(y₂-y₁)²+(z₂-z₁)²)\n'
        'Line: (x-x₁)/a = (y-y₁)/b = (z-z₁)/c\n'
        'Angle between lines: cosθ = |a₁a₂+b₁b₂+c₁c₂|/(√Σa₁²√Σa₂²)\n'
        'Plane: ax+by+cz+d=0\n'
        'Distance point to plane: d = |ax₁+by₁+cz₁+d|/√(a²+b²+c²)',
    detailedNotes:
        '3D coordinate system: three mutually perpendicular axes.\n'
        'Vector form of line: r = a + λb.\n'
        'Skew lines: not parallel, not intersecting. Shortest distance.\n'
        'Angle between line and plane: sinφ = |a·n|/(|a||n|).\n'
        'Equation of plane: normal form, intercept form, three-point form.\n'
        'Intersection of line and plane: substitute parametric into equation.',
    examples:
        'Q1: Find direction cosines of line through (1,2,3) and (4,5,6).\nSolution: d = (3,3,3), dirl = 3/√27 = 1/√3. l=m=n=1/√3\n\n'
        'Q2: Distance from (1,1,1) to plane 2x+3y+6z-12=0.\nSolution: d = |2+3+6-12|/√(4+9+36) = 1/7',
    practiceProblems:
        '1. Find equation of line through (1,-2,3) parallel to (2,1,-3).\n'
        '2. Find angle between lines: (x-1)/2 = (y+2)/-1 = z/3 and x/1 = (y-1)/2 = (z+3)/-1.\n'
        '3. Find equation of plane through (1,2,3) perpendicular to line with drs (2,1,-2).\n'
        '4. Find shortest distance between lines r = i+2j+λ(2i+j-k) and r = 3i+4j+μ(i+2j+k).',
  ),
  Chapter(
    id: 16,
    name: 'Probability',
    subject: 'Mathematics',
    pages: 24,
    weightage: 14,
    keyFormulas:
        'P(A∪B) = P(A)+P(B)-P(A∩B)\n'
        'Conditional: P(A|B) = P(A∩B)/P(B)\n'
        'Bayes\': P(A|B) = P(B|A)P(A)/P(B)\n'
        'Binomial: P(X=r) = ⁿCr pʳqⁿ⁻ʳ\n'
        'Mean: μ = np, Variance: σ² = npq\n'
        'Bernoulli trials: exactly 2 outcomes, constant p',
    detailedNotes:
        'Probability: measure of likelihood, between 0 and 1.\n'
        'Total probability: P(B) = ΣP(Ai)P(B|Ai).\n'
        'Independent events: P(A∩B)=P(A)P(B).\n'
        'Random variable: assigns number to each outcome.\n'
        'Probability distribution: table of X and P(X).\n'
        'Bayes\' theorem: reverse conditional probability.\n'
        'Applications: genetics, quality control, decision theory.',
    examples:
        'Q1: Two dice thrown. Probability sum=7?\nSolution: Favourable (1,6),(2,5),(3,4),(4,3),(5,2),(6,1) = 6/36 = 1/6\n\n'
        'Q2: Bag: 4R, 3B balls. P(both red) without replacement.\nSolution: (4/7)×(3/6) = 12/42 = 2/7',
    practiceProblems:
        '1. Find P(at least one head) in 3 coin tosses.\n'
        '2. A card drawn from deck. Find P(king or heart).\n'
        '3. Box: 5 defective, 15 good. P(exactly 2 defective in 4 items).\n'
        '4. Using Bayes: Bag A: 3R,4W; Bag B: 5R,2W. P(bag A given white drawn).',
  ),
  Chapter(
    id: 17,
    name: 'Reproduction in Organisms',
    subject: 'Biology',
    pages: 18,
    weightage: 10,
    keyFormulas:
        'No major formulas. Key concepts:\n'
        'Asexual: binary fission, budding, fragmentation, spore formation\n'
        'Sexual: gametogenesis, fertilization, embryogenesis\n'
        'Phases: juvenile → reproductive → senescent',
    detailedNotes:
        'Reproduction: biological process producing offspring.\n'
        'Asexual: identical clones, rapid, no genetic variation.\n'
        'Binary fission: Amoeba, Paramecium. Budding: Hydra, yeast.\n'
        'Sexual: involves two parents, fusion of gametes.\n'
        'External fertilization: in water (fish, frogs).\n'
        'Internal fertilization: inside female body.\n'
        'Oviparous: lay eggs. Viviparous: give birth to young.',
    examples:
        'Q1: Name type of reproduction in Hydra.\nSolution: Budding (asexual) and also sexual.\n\n'
        'Q2: Difference between zoospores and zygospores.\nSolution: Zoospores are motile (asexual), zygospores are thick-walled (sexual).',
    practiceProblems:
        '1. List advantages of sexual reproduction over asexual.\n'
        '2. Define: hermaphrodite, gametogenesis, embryogenesis.\n'
        '3. Why is external fertilization less common on land?\n'
        '4. Arrange in sequence: fertilization, gametogenesis, embryogenesis, zygote.',
  ),
  Chapter(
    id: 18,
    name: 'Principles of Inheritance and Variation',
    subject: 'Biology',
    pages: 22,
    weightage: 14,
    keyFormulas:
        'Mendelian ratio: 3:1 (monohybrid), 9:3:3:1 (dihybrid)\n'
        'Probability of genotype: (¾)ⁿ for dominant\n'
        'Hardy-Weinberg: p² + 2pq + q² = 1\n'
        'Recombination frequency = (recombinants/total)×100',
    detailedNotes:
        'Mendel\'s laws: dominance, segregation, independent assortment.\n'
        'Punnett square predicts offspring genotypes.\n'
        'Incomplete dominance: intermediate phenotype (4 o\'clock plant).\n'
        'Co-dominance: both alleles expressed (AB blood group).\n'
        'Multiple alleles: more than 2 alleles for gene (ABO system).\n'
        'Sex determination: XX-XY, ZZ-ZW, haplodiploid.\n'
        'Linkage and recombination: genes on same chromosome.',
    examples:
        'Q1: Monohybrid cross: Tt × Tt. Probability tall?\nSolution: TT(1), Tt(2), tt(1). Tall = 3/4 or 75%\n\n'
        'Q2: Blood group A mother, B father, child O. Genotypes?\nSolution: Mother AO, Father BO, child OO.',
    practiceProblems:
        '1. In pea, round(R) dominant over wrinkled(r). RR × rr. Find F1 and F2.\n'
        '2. A man with blood group A marries woman with B. What blood groups possible in children?\n'
        '3. Explain incomplete dominance with example.\n'
        '4. In population, frequency of recessive allele = 0.3. Find frequency of heterozygotes.',
  ),
  Chapter(
    id: 19,
    name: 'Molecular Basis of Inheritance',
    subject: 'Biology',
    pages: 24,
    weightage: 16,
    keyFormulas:
        'DNA structure: double helix, antiparallel\n'
        'Chargaff\'s rule: A=T, G=C\n'
        'Central dogma: DNA → RNA → Protein\n'
        'Replication: semiconservative\n'
        'Transcription: DNA → mRNA\nTranslation: mRNA → Protein\n'
        'Genetic code: triplet, degenerate, universal',
    detailedNotes:
        'DNA: genetic material in most organisms (RNA in some viruses).\n'
        'Griffith\'s experiment: transformation in bacteria.\n'
        'Hershey-Chase: DNA is genetic material (phage experiment).\n'
        'Meselson-Stahl: semiconservative replication.\n'
        'RNA: mRNA (messenger), tRNA (transfer), rRNA (ribosomal).\n'
        'Lac operon: inducible system in E. coli.\n'
        'Human genome project: 2003, ~3 billion base pairs.',
    examples:
        'Q1: If DNA has 30% A, find %G.\nSolution: A=T=30%, G=C, so G = (100-60)/2 = 20%\n\n'
        'Q2: Template strand: 3\'-TAC-5\'. What is mRNA codon?\nSolution: 5\'-AUG-3\' (codes for methionine)',
    practiceProblems:
        '1. Explain Meselson-Stahl experiment.\n'
        '2. Differentiate between leading and lagging strand.\n'
        '3. What is the role of tRNA in translation?\n'
        '4. A DNA fragment is 3400Å long. How many base pairs?\n(one base pair = 3.4Å)',
  ),
  Chapter(
    id: 20,
    name: 'Biomolecules',
    subject: 'Biology',
    pages: 18,
    weightage: 12,
    keyFormulas:
        'Carbohydrates: (CH₂O)n where n≥3\n'
        'Proteins: amino acids linked by peptide bonds\n'
        'Enzyme kinetics: V₀ = Vmax[S]/(Km+[S])\n'
        'DNA helix: 20Å diameter, 3.4Å per base pair, 34Å per turn',
    detailedNotes:
        'Carbohydrates: monosaccharides, disaccharides, polysaccharides.\n'
        'Proteins: primary (sequence), secondary (α-helix, β-sheet), tertiary, quaternary.\n'
        'Lipids: fats, oils, phospholipids, steroids.\n'
        'Nucleic acids: DNA, RNA - polymers of nucleotides.\n'
        'Enzymes: biological catalysts, lower activation energy.\n'
        'Factors affecting enzyme activity: temperature, pH, substrate concentration.\n'
        'Vitamins: organic compounds required in small amounts.',
    examples:
        'Q1: Name bond linking amino acids.\nSolution: Peptide bond (between -COOH and -NH₂)\n\n'
        'Q2: Two monosaccharides in sucrose.\nSolution: Glucose + Fructose',
    practiceProblems:
        '1. Differentiate between fibrous and globular proteins with examples.\n'
        '2. What are essential amino acids? Give two examples.\n'
        '3. Explain lock and key model of enzyme action.\n'
        '4. Name vitamin deficiency diseases: A, C, D, B12.',
  ),
  Chapter(
    id: 21,
    name: 'Sexual Reproduction in Flowering Plants',
    subject: 'Biology',
    pages: 18,
    weightage: 12,
    keyFormulas:
        'No major formulas. Key stages:\n'
        'Microsporogenesis: pollen grain formation\n'
        'Megasporogenesis: embryo sac formation\n'
        'Double fertilization: 2 male gametes → zygote + endosperm\n'
        'Embryogenesis: proembryo → globular → heart → mature',
    detailedNotes:
        'Flower: reproductive structure in angiosperms.\n'
        'Stamen: anther + filament. Microsporangium → pollen grains.\n'
        'Pistil: stigma, style, ovary. Ovule contains embryo sac.\n'
        'Pollination: transfer of pollen to stigma. Self vs cross.\n'
        'Agents: wind, water, insects, birds.\n'
        'Double fertilization: unique to angiosperms.\n'
        'Fruit: mature ovary. Seed: mature ovule.',
    examples:
        'Q1: What is double fertilization?\nSolution: Fusion of one male gamete with egg (zygote) and other with polar nuclei (endosperm).\n\n'
        'Q2: Name the part developing into seed.\nSolution: Ovule (after fertilization)',
    practiceProblems:
        '1. Draw labelled diagram of a typical anatropous ovule.\n'
        '2. Differentiate between wind-pollinated and insect-pollinated flowers.\n'
        '3. What is the function of filiform apparatus?\n'
        '4. Explain development of dicot embryo.',
  ),
  Chapter(
    id: 22,
    name: 'Biotechnology: Principles and Processes',
    subject: 'Biology',
    pages: 20,
    weightage: 12,
    keyFormulas:
        'rDNA steps: cut → ligate → transform → screen → express\n'
        'PCR: denaturation (94°C), annealing (50-65°C), extension (72°C)\n'
        'Gel electrophoresis: DNA moves to +ve electrode\n'
        'DNA ligase joins DNA fragments\n'
        'Restriction enzymes: cut at palindromic sequences',
    detailedNotes:
        'Biotechnology: use of living organisms for human benefit.\n'
        'Restriction enzymes: molecular scissors. EcoRI, HindIII.\n'
        'Vectors: plasmids (pBR322), bacteriophages, cosmids.\n'
        'Competent host: treated with CaCl₂ to take up DNA.\n'
        'Bioreactor: vessel for large-scale culture.\n'
        'Downstream processing: purification of product.\n'
        'Applications: insulin production, gene therapy, GMOs.',
    examples:
        'Q1: Name first restriction enzyme isolated.\nSolution: HindII (from Haemophilus influenzae)\n\n'
        'Q2: Why is E. coli used as host for rDNA?\nSolution: Well-characterized genome, easy to culture, rapid growth.',
    practiceProblems:
        '1. Explain steps in recombinant DNA technology.\n'
        '2. Describe the role of: (a) EcoRI (b) DNA ligase (c) plasmid.\n'
        '3. Write the steps of PCR with temperatures.\n'
        '4. What are palindromic sequences? Give example.',
  ),
];
