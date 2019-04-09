Bertan Hallacoglu*, Giles Blaney**, Angelo Sassaroli, and Sergio Fantini
Diffuse Optical Imaging of Tissue (DOIT) Lab
Department of Biomedical Engineering, Tufts University, Medford MA USA
* bertan.hallacoglu@tufts.edu, hallacoglub@gmail.com
** giles.blaney@tufts.edu

Forward and inverse model for frequency domain photon diffusion in two-layer diffuse media. Note that data used for inverse model should be amplitude and phase from multiple source detector distances and of good quality.

FORWARD MODEL: TwoLayerReflectance.m (Requires zeroOrdBesselRoots.mat)
INVERSE MODEL: TwoLayer_InverseMarquardt.m (Requires TwoLayerReflectance.m and zeroOrdBesselRoots.mat)

Two-layer reflectance forward and inverse model described in:
Hallacoglu B, Sassaroli A, Fantini S (2013) Optical Characterization of Two-Layered Turbid Media for Non-Invasive, Absolute Oximetry in Cerebral and Extracerebral Tissue. PLoS ONE 8(5): e64095. doi:10.1371/journal.pone.0064095

