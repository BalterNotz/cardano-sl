module Test.Pos.Core.Gen
       (
        -- Pos.Core.Block Generators
          genBlockBodyAttributes
        , genBlockHeader
        , genBlockHeaderAttributes
        , genBlockSignature
        , genGenesisBlockHeader
        , genGenesisBody
        , genGenesisConsensusData
        , genGenesisHash
        , genGenesisProof
        , genHeaderHash
        , genMainBlockHeader
        , genMainBody
        , genMainConsensusData
        , genMainExtraBodyData
        , genMainExtraHeaderData
        , genMainProof
        , genMainToSign

        -- Pos.Core.Common Generators
        , genAddrAttributes
        , genAddress
        , genAddrSpendingData
        , genAddrStakeDistribution
        , genAddrType
        , genBlockCount
        , genChainDifficulty
        , genCoeff
        , genCoin
        , genCoinPortion
        , genScript
        , genScriptVersion
        , genSharedSeed
        , genSlotLeaders
        , genStakeholderId
        , genStakesList
        , genStakesMap
        , genTxFeePolicy
        , genTxSizeLinear

        -- Pos.Core.Configuration Generators
        , genGenesisConfiguration
        , genCoreConfiguration

        -- Pos.Core.Delegation Generators
        , genDlgPayload
        , genHeavyDlgIndex
        , genLightDlgIndices
        , genProxySKBlockInfo
        , genProxySKHeavy

        -- Pos.Core.Genesis Generators
        , genFakeAvvmOptions
        , genGenesisAvvmBalances
        , genGenesisDelegation
        , genGenesisProtocolConstants
        , genGenesisSpec
        , genTestnetBalanceOptions

        -- Pos.Core.ProtocolConstants
        , genVssMaxTTL
        , genVssMinTTL

        -- Pos.Core.Slotting Generators
        , genEpochIndex
        , genEpochOrSlot
        , genFlatSlotId
        , genLocalSlotIndex
        , genSlotCount
        , genSlotId
        , genTimeDiff
        , genTimestamp

        -- Pos.Core.Ssc Generators
        , genCommitment
        , genCommitmentsMap
        , genCommitmentSignature
        , genInnerSharesMap
        , genSharesMap
        , genOpening
        , genOpeningsMap
        , genSscPayload
        , genSscProof
        , genSharesDistribution
        , genSignedCommitment
        , genVssCertificate
        , genVssCertificatesHash
        , genVssCertificatesMap

        -- Pos.Core.Txp Generators
        , genPkWitness
        , genRedeemWitness
        , genScriptWitness
        , genTx
        , genTxAttributes
        , genTxAux
        , genTxHash
        , genTxId
        , genTxIn
        , genTxInList
        , genTxInWitness
        , genTxOut
        , genTxOutAux
        , genTxOutList
        , genTxPayload
        , genTxProof
        , genTxSig
        , genTxSigData
        , genTxWitness
        , genUnknownWitnessType

        -- Pos.Core.Update Generators
        , genApplicationName
        , genBlockVersion
        , genBlockVersionData
        , genBlockVersionModifier
        , genHashRaw
        , genSoftforkRule
        , genSoftwareVersion
        , genSystemTag
        , genUpAttributes
        , genUpdateData
        , genUpdatePayload
        , genUpdateProof
        , genUpdateProposal
        , genUpdateProposals
        , genUpdateProposalToSign
        , genUpdateVote
        , genUpId
        , genUpsData
        , genVoteId

        -- Pos.Data.Attributes Generators
        , genAttributes

        -- Pos.Merkle Generators
        , genMerkleRoot
        , genMerkleTree
       ) where

import           Universum

import           Data.ByteString.Base16 as B16
import           Data.Coerce (coerce)
import           Data.Either (either)
import           Data.Fixed (Fixed (..))
import qualified Data.HashMap.Strict as HM
import           Data.List.NonEmpty (fromList)
import qualified Data.Map as M
import           Data.Maybe
import           Data.Time.Units (fromMicroseconds, Microsecond, Millisecond)
import qualified Data.Vector as V
import           Hedgehog
import qualified Hedgehog.Gen as Gen
import qualified Hedgehog.Range as Range
import           Pos.Binary.Class (asBinary, Bi, Raw (..))
import           Pos.Core.Block (BlockBodyAttributes, BlockHeader (..),
                                 BlockHeaderAttributes, BlockSignature (..),
                                 GenesisBlockHeader, GenesisBody (..),
                                 GenesisConsensusData (..), GenesisProof (..),
                                 HeaderHash,
                                 MainBlockHeader, MainBody (..),
                                 MainConsensusData (..),
                                 MainExtraBodyData (..),
                                 MainExtraHeaderData (..), MainProof (..),
                                 MainToSign (..), mkMainHeaderExplicit, mkGenesisHeader)
import           Pos.Core.Common (Address (..), AddrAttributes (..),
                                  AddrSpendingData (..),
                                  AddrStakeDistribution (..), AddrType (..),
                                  BlockCount (..), ChainDifficulty (..),
                                  Coeff (..), Coin (..), CoinPortion (..),
                                  makeAddress, Script (..), ScriptVersion,
                                  SharedSeed (..), SlotLeaders, StakeholderId,
                                  StakesList, StakesMap, TxFeePolicy (..),
                                  TxSizeLinear (..), coinPortionDenominator, mkMultiKeyDistr)
import           Pos.Core.Configuration (CoreConfiguration (..),
                                         GenesisConfiguration (..),
                                         GenesisHash (..))
import           Pos.Core.Delegation (HeavyDlgIndex (..), LightDlgIndices (..),
                                      ProxySKHeavy, DlgPayload (..), ProxySKBlockInfo)
import           Pos.Core.Genesis (FakeAvvmOptions (..),
                                   GenesisAvvmBalances (..),
                                   GenesisDelegation (..),
                                   GenesisInitializer (..),
                                   GenesisProtocolConstants (..),
                                   GenesisSpec (..), mkGenesisSpec,
                                   TestnetBalanceOptions (..))
import           Pos.Core.ProtocolConstants (VssMinTTL (..), VssMaxTTL (..))
import           Pos.Core.Slotting (EpochIndex (..), EpochOrSlot (..),
                                    FlatSlotId, LocalSlotIndex (..),
                                    SlotCount (..), SlotId (..), TimeDiff (..),
                                    Timestamp (..))
import           Pos.Core.Ssc (Commitment, CommitmentSignature, CommitmentsMap,
                               mkCommitmentsMap, mkSscProof, mkVssCertificate,
                               mkVssCertificatesMap, Opening, OpeningsMap,
                               InnerSharesMap, SharesDistribution, SharesMap,
                               SignedCommitment, SscPayload (..), SscProof,
                               VssCertificate (..), VssCertificatesHash,
                               VssCertificatesMap (..), randCommitmentAndOpening)
import           Pos.Core.Txp (Tx (..), TxAttributes, TxAux (..), TxId,
                               TxIn (..), TxInWitness (..), TxOut (..),
                               TxOutAux (..), TxPayload (..), TxProof (..),
                               TxSig, TxSigData (..), TxWitness, mkTxPayload)
import           Pos.Core.Update (ApplicationName (..), BlockVersion (..),
                                  BlockVersionData (..),
                                  BlockVersionModifier (..), SoftforkRule (..),
                                  SoftwareVersion (..), SystemTag (..),
                                  UpAttributes, UpdateData (..),
                                  UpdatePayload (..), UpdateProof,
                                  UpdateProposal (..), UpdateProposals,
                                  UpdateProposalToSign  (..), UpdateVote (..),
                                  UpId, VoteId, mkUpdateVote)
import           Pos.Crypto (decodeHash, deterministic, Hash, ProtocolMagic, hash, safeCreatePsk, sign)
import           Pos.Data.Attributes (Attributes (..), mkAttributes)
import           Pos.Merkle (mkMerkleTree, mtRoot, MerkleRoot(..),
                             MerkleTree (..))
import           Pos.Util.Util (leftToPanic)
import           Serokell.Data.Memory.Units (Byte)

import           Test.Pos.Crypto.Gen (genAbstractHash, genDecShare,
                                      genHDAddressPayload,genProtocolMagic,
                                      genProxySignature,genPublicKey,
                                      genRedeemPublicKey, genRedeemSignature,
                                      genSafeSigner, genSecretKey,
                                      genSignature, genSignTag,
                                      genVssPublicKey)


----------------------------------------------------------------------------
-- Pos.Core.Block Generators
----------------------------------------------------------------------------

genBlockBodyAttributes :: Gen BlockBodyAttributes
genBlockBodyAttributes = pure $ mkAttributes ()

genBlockHeader :: Gen BlockHeader
genBlockHeader =
    Gen.choice [ BlockHeaderGenesis <$> (genGenesisBlockHeader =<< genProtocolMagic)
               , BlockHeaderMain <$> genMainBlockHeader
               ]

genBlockHeaderAttributes :: Gen BlockHeaderAttributes
genBlockHeaderAttributes = pure $ mkAttributes ()

-- fails
genBlockSignature :: ProtocolMagic -> Gen BlockSignature
genBlockSignature pm =
    Gen.choice
        [ BlockSignature
              <$> genSignature pm genMainToSign
        , BlockPSignatureLight
              <$> genProxySignature genMainToSign genLightDlgIndices
        , BlockPSignatureHeavy
              <$> genProxySignature genMainToSign genHeavyDlgIndex
        ]

-- crashes - bad signatures
genGenesisBlockHeader :: ProtocolMagic -> Gen GenesisBlockHeader
genGenesisBlockHeader pm =
    mkGenesisHeader pm
        <$> Gen.choice gens
        <*> genEpochIndex
        <*> genGenesisBody
  where
    gens = [ Left <$> genGenesisHash
           , Right <$> genBlockHeader
           ]

genGenesisBody :: Gen GenesisBody
genGenesisBody = GenesisBody <$> genSlotLeaders

genGenesisConsensusData :: Gen GenesisConsensusData
genGenesisConsensusData =
    GenesisConsensusData
        <$> genEpochIndex
        <*> genChainDifficulty

genGenesisHash :: Gen GenesisHash
genGenesisHash = do
  sampleText <- Gen.text (Range.linear 0 10) Gen.alphaNum
  pure $ GenesisHash (coerce (hash sampleText :: Hash Text))

-- TODO is this right?
genHeaderHash :: Gen HeaderHash
genHeaderHash = do
  sampleText <- Gen.text (Range.linear 0 10) Gen.alphaNum
  pure (coerce (hash sampleText :: Hash Text))

genGenesisProof :: Gen GenesisProof
genGenesisProof = GenesisProof <$> genAbstractHash genSlotLeaders


-- genMainBlockBody
--     :: ProtocolMagic
--     -> Core.EpochIndex -- ^ For the delegation payload.
--     -> Gen T.MainBody
-- genMainBlockBody pm epoch =
--     T.MainBody <$> genTxPayload pm
--                <*> genSscPayload pm
--                <*> genDlgPayload pm epoch
--                <*> genUpdatePayload pm
-- TODO should we take an EpochIndex?
genMainBody :: ProtocolMagic -> Gen MainBody
genMainBody pm =
    MainBody
        <$> genTxPayload pm
        <*> genSscPayload pm
        <*> genDlgPayload pm
        <*> genUpdatePayload pm

-- crashes - bad signatures
genMainBlockHeader :: Gen MainBlockHeader
genMainBlockHeader =
    mkMainHeaderExplicit
        <$> genProtocolMagic
        <*> genHeaderHash
        <*> genChainDifficulty
        <*> genSlotId
        <*> genSecretKey
        <*> genProxySKBlockInfo
        <*> (genMainBody =<< genProtocolMagic)
        <*> genMainExtraHeaderData

genMainConsensusData :: Gen MainConsensusData
genMainConsensusData =
    MainConsensusData
        <$> genSlotId
        <*> genPublicKey
        <*> genChainDifficulty
        <*> (genBlockSignature =<< genProtocolMagic)


genMainExtraBodyData :: Gen MainExtraBodyData
genMainExtraBodyData = MainExtraBodyData <$> genBlockBodyAttributes

genMainExtraHeaderData :: Gen MainExtraHeaderData
genMainExtraHeaderData =
    MainExtraHeaderData
        <$> genBlockVersion
        <*> genSoftwareVersion
        <*> genBlockHeaderAttributes
        <*> genAbstractHash genMainExtraBodyData

-- slow
-- TODO figure out if all fields must use the same `pm`
genMainProof :: Gen MainProof
genMainProof =
    MainProof
        <$> (genTxProof =<< genProtocolMagic)
        <*> (genSscProof =<< genProtocolMagic)
        <*> genAbstractHash (genDlgPayload =<< genProtocolMagic)
        <*> (genUpdateProof =<< genProtocolMagic)

genMainToSign :: Gen MainToSign
genMainToSign =
    MainToSign
        <$> genAbstractHash genBlockHeader
        <*> genMainProof
        <*> genSlotId
        <*> genChainDifficulty
        <*> genMainExtraHeaderData

----------------------------------------------------------------------------
-- Pos.Core.Common Generators
----------------------------------------------------------------------------

genAddrAttributes :: Gen AddrAttributes
genAddrAttributes = AddrAttributes <$> hap <*> genAddrStakeDistribution
  where
    hap = Gen.maybe genHDAddressPayload

genAddress :: Gen Address
genAddress = makeAddress <$> genAddrSpendingData <*> genAddrAttributes

genAddrType :: Gen AddrType
genAddrType = Gen.choice [ pure ATPubKey
                         , pure ATScript
                         , pure ATRedeem
                         -- Values 0,1,2 are reserved, as they are used to tag
                         -- the above 3 constructors --------------+
                         --                                        |
                         , ATUnknown <$> Gen.word8 (Range.constant 3 maxBound)
                         ]

genAddrSpendingData :: Gen AddrSpendingData
genAddrSpendingData = Gen.choice gens
  where
    gens = [ PubKeyASD <$> genPublicKey
           , ScriptASD <$> genScript
           , RedeemASD <$> genRedeemPublicKey
           -- Values 0,1,2 are reserved, as they are used to tag
           -- the above 3 constructors ---------------+
           --                                         |
           , UnknownASD <$> Gen.word8 (Range.constant 3 maxBound) <*> gen32Bytes
           ]

genAddrStakeDistribution :: Gen AddrStakeDistribution
genAddrStakeDistribution = Gen.choice gens
  where
    gens = [ pure BootstrapEraDistr
           , SingleKeyDistr <$> genStakeholderId
           , leftToPanic "arbitrary @AddrStakeDistribution: " .
             mkMultiKeyDistr <$>
             genMultiKeyDistr
           ]
    -- genMap = Gen.map (Range.linear 0 10) genPair
    -- genPair = do
    --   si <- genStakeholderId
    --   cp <- genCoinPortion
    --   pure (si, cp)

    -- Lifted from `Pos.Arbitrary.Core`. There are very particular constraints
    -- on the AddrStakeDistribution, which are mixed into encoding/decoding.
    genMultiKeyDistr :: Gen (Map StakeholderId CoinPortion)
    -- We don't want to generate too much, hence 'scale'.
    genMultiKeyDistr =
        Gen.scale (min 16) $ do
            holder0 <- genStakeholderId
            holder1 <- Gen.filter (/= holder0) genStakeholderId
            -- TODO figure out a good size bound here
            moreHolders <- Gen.list (Range.linear 0 100) genStakeholderId
            -- Must be at least 2 non-repeating stakeholders.
            let holders = ordNub (holder0 : holder1 : moreHolders)
            portions <- genPortions (length holders) []
            return $ M.fromList $ holders `zip` portions
    genPortions :: Int -> [CoinPortion] -> Gen [CoinPortion]
    genPortions 0 res = pure res
    genPortions n res = do
        let limit =
                foldl' (-) coinPortionDenominator $
                map getCoinPortion res
        case (n, limit) of
            -- Limit is exhausted, can't create more.
            (_, 0) -> return res
            -- The last portion, we must ensure the sum is correct.
            (1, _) -> return (CoinPortion limit : res)
            -- We intentionally don't generate 'limit', because we
            -- want to generate at least 2 portions.  However, if
            -- 'limit' is 1, we will generate 1, because we must
            -- have already generated one portion.
            _ -> do
                portion <-
                    CoinPortion <$> Gen.word64 (Range.linear 1 (max 1 (limit - 1)))
                genPortions (n - 1) (portion : res)

genBlockCount :: Gen BlockCount
genBlockCount = BlockCount <$> Gen.word64 Range.constantBounded

genChainDifficulty :: Gen ChainDifficulty
genChainDifficulty = ChainDifficulty <$> genBlockCount

genCoeff :: Gen Coeff
genCoeff = do
    integer <- Gen.integral (Range.constant 0 10)
    pure $ Coeff (MkFixed integer)

genCoin :: Gen Coin
genCoin = Coin <$> Gen.word64 (Range.constant 0 100000000)

genCoinPortion :: Gen CoinPortion
genCoinPortion = CoinPortion <$> Gen.word64 (Range.constant 1 1000)

genScript :: Gen Script
genScript = Script <$> genScriptVersion <*> gen32Bytes

genScriptVersion :: Gen ScriptVersion
genScriptVersion = Gen.word16 Range.constantBounded

genSharedSeed :: Gen SharedSeed
genSharedSeed = SharedSeed <$> gen32Bytes

genSlotLeaders :: Gen SlotLeaders
genSlotLeaders = do
    stakeHolderList <- Gen.list (Range.linear 1 10) genStakeholderId
    pure $ fromJust $ nonEmpty stakeHolderList

genStakeholderId :: Gen StakeholderId
genStakeholderId = genAbstractHash genPublicKey

genStakesList :: Gen StakesList
genStakesList = Gen.list range gen
  where
    gen = (,) <$> genStakeholderId <*> genCoin
    range = Range.linear 0 10

genStakesMap :: Gen StakesMap
genStakesMap = genCustomHashMap genStakeholderId genCoin

genTxFeePolicy :: Gen TxFeePolicy
genTxFeePolicy =
    Gen.choice [ TxFeePolicyTxSizeLinear <$> genTxSizeLinear
               , TxFeePolicyUnknown <$> genUnknownPolicy <*> gen32Bytes
               ]
  where
    -- 0 is a reserved policy, so we go from 1 to max.
    -- The Bi instance decoder for TxFeePolicy consolidates the
    -- tag and the policy number, so a 0 policy in TxFeePolicyUnknown
    -- causes a decoder error.
    genUnknownPolicy :: Gen Word8
    genUnknownPolicy = Gen.word8 (Range.constant 1 maxBound)

genTxSizeLinear :: Gen TxSizeLinear
genTxSizeLinear = TxSizeLinear <$> genCoeff <*> genCoeff

----------------------------------------------------------------------------
-- Pos.Core.Configuration Generators
----------------------------------------------------------------------------

genGenesisConfiguration :: Gen GenesisConfiguration
genGenesisConfiguration =
    Gen.choice [ GCSrc
                     <$> Gen.string (Range.constant 10 25) Gen.alphaNum
                     <*> genHashRaw
               , GCSpec <$> genGenesisSpec
               ]

genCoreConfiguration :: Gen CoreConfiguration
genCoreConfiguration =
    CoreConfiguration
        <$> genGenesisConfiguration
        <*> genWord8

----------------------------------------------------------------------------
-- Pos.Core.Delegation Generators
----------------------------------------------------------------------------

genDlgPayload :: ProtocolMagic -> Gen DlgPayload
genDlgPayload pm =
    UnsafeDlgPayload <$> Gen.list (Range.constant 0 10) (genProxySKHeavy pm)

genHeavyDlgIndex :: Gen HeavyDlgIndex
genHeavyDlgIndex = HeavyDlgIndex <$> genEpochIndex

genLightDlgIndices :: Gen LightDlgIndices
genLightDlgIndices =
    LightDlgIndices <$> ((,) <$> genEpochIndex <*> genEpochIndex)

genProxySKBlockInfo :: Gen ProxySKBlockInfo
genProxySKBlockInfo = do
    pSKHeavy <- (genProxySKHeavy =<< genProtocolMagic)
    pubKey <- genPublicKey
    pure $ Just (pSKHeavy,pubKey)

genProxySKHeavy :: ProtocolMagic -> Gen ProxySKHeavy
genProxySKHeavy pm =
    safeCreatePsk pm
        <$> genSafeSigner
        <*> genPublicKey
        <*> genHeavyDlgIndex

----------------------------------------------------------------------------
-- Pos.Core.Genesis Generators
----------------------------------------------------------------------------

genFakeAvvmOptions :: Gen FakeAvvmOptions
genFakeAvvmOptions =
    FakeAvvmOptions
        <$> Gen.word Range.constantBounded
        <*> Gen.word64 Range.constantBounded

genGenesisDelegation :: Gen GenesisDelegation
genGenesisDelegation =
    UnsafeGenesisDelegation
        <$> customHashMapGen genStakeholderId
                             (genProxySKHeavy =<< genProtocolMagic)

genGenesisInitializer :: Gen GenesisInitializer
genGenesisInitializer =
    GenesisInitializer
        <$> genTestnetBalanceOptions
        <*> genFakeAvvmOptions
        <*> genCoinPortion
        <*> Gen.bool
        <*> Gen.integral (Range.constant 0 10)

genGenesisProtocolConstants :: Gen GenesisProtocolConstants
genGenesisProtocolConstants =
    GenesisProtocolConstants
        <$> Gen.int (Range.constant 0 100)
        <*> genProtocolMagic
        <*> genVssMaxTTL
        <*> genVssMinTTL

genGenesisSpec :: Gen GenesisSpec
genGenesisSpec = mkGenSpec >>=  either (error . toText) pure
    where
        mkGenSpec = mkGenesisSpec
                      <$> genGenesisAvvmBalances
                      <*> genSharedSeed
                      <*> genGenesisDelegation
                      <*> genBlockVersionData
                      <*> genGenesisProtocolConstants
                      <*> genGenesisInitializer

genTestnetBalanceOptions :: Gen TestnetBalanceOptions
genTestnetBalanceOptions =
    TestnetBalanceOptions
        <$> Gen.word Range.constantBounded
        <*> Gen.word Range.constantBounded
        <*> Gen.word64 Range.constantBounded
        <*> Gen.double (Range.constant 0 10)
        <*> Gen.bool
----------------------------------------------------------------------------
-- Pos.Core.ProtocolConstants Generators
----------------------------------------------------------------------------

genVssMaxTTL :: Gen VssMaxTTL
genVssMaxTTL = VssMaxTTL <$> genWord32

genVssMinTTL :: Gen VssMinTTL
genVssMinTTL = VssMinTTL <$> genWord32

----------------------------------------------------------------------------
-- Pos.Core.Slotting Generators
----------------------------------------------------------------------------

genEpochIndex :: Gen EpochIndex
genEpochIndex = EpochIndex <$> Gen.word64 Range.constantBounded

genEpochOrSlot :: Gen EpochOrSlot
genEpochOrSlot =
    Gen.choice [ EpochOrSlot . Left <$> genEpochIndex
               , EpochOrSlot . Right <$> genSlotId
               ]

genFlatSlotId :: Gen FlatSlotId
genFlatSlotId = Gen.word64 Range.constantBounded

genLocalSlotIndex :: Gen LocalSlotIndex
genLocalSlotIndex = UnsafeLocalSlotIndex <$> Gen.word16 (Range.constant 0 21599)

genSlotCount :: Gen SlotCount
genSlotCount = SlotCount <$> Gen.word64 Range.constantBounded

genSlotId :: Gen SlotId
genSlotId = SlotId <$> genEpochIndex <*> genLocalSlotIndex

genTimeDiff :: Gen TimeDiff
genTimeDiff = TimeDiff <$> genMicrosecond

genTimestamp :: Gen Timestamp
genTimestamp = Timestamp <$> genMicrosecond

----------------------------------------------------------------------------
-- Pos.Core.Ssc Generators
----------------------------------------------------------------------------

genGenesisAvvmBalances :: Gen GenesisAvvmBalances
genGenesisAvvmBalances = GenesisAvvmBalances <$> customHashMapGen genRedeemPublicKey genCoin

genCommitment :: Gen Commitment
genCommitment = fst <$> genCommitmentOpening

genCommitmentOpening :: Gen (Commitment, Opening)
genCommitmentOpening = do
    let numKeys = 128 :: Int
    parties <-
        Gen.integral (Range.constant 4 (fromIntegral numKeys)) :: Gen Integer
    threshold <- Gen.integral (Range.constant 2 (parties - 2)) :: Gen Integer
    vssKeys <- replicateM numKeys genVssPublicKey
    pure
        $ deterministic "commitmentOpening"
        $ randCommitmentAndOpening threshold (fromList vssKeys)

genCommitmentSignature :: ProtocolMagic -> Gen CommitmentSignature
genCommitmentSignature pm = genSignature pm $ (,) <$> genEpochIndex <*> genCommitment

genCommitmentsMap :: ProtocolMagic -> Gen CommitmentsMap
genCommitmentsMap pm = mkCommitmentsMap <$> Gen.list range (genSignedCommitment pm)
  where
    range = Range.linear 0 10

genInnerSharesMap :: Gen InnerSharesMap
genInnerSharesMap = do
    hMS <- Gen.int (Range.constant 0 20)
    stakeholderId <- Gen.list (Range.singleton hMS) genStakeholderId
    nonEmptyDS <- Gen.nonEmpty (Range.singleton hMS) (asBinary <$> genDecShare)
    pure $ HM.fromList $ zip stakeholderId [nonEmptyDS]

genOpening :: Gen Opening
genOpening = snd <$> genCommitmentOpening

genOpeningsMap :: Gen OpeningsMap
genOpeningsMap = do
    hMapSize <- Gen.int (Range.constant 0 20)
    stakeholderId <- Gen.list (Range.singleton hMapSize) genStakeholderId
    opening <- Gen.list (Range.singleton hMapSize) genOpening
    pure $ HM.fromList $ zip stakeholderId opening

genSharesDistribution :: Gen SharesDistribution
genSharesDistribution = genCustomHashMap genStakeholderId genWord16
  where
    genWord16 = Gen.word16 Range.constantBounded

genSharesMap :: Gen SharesMap
genSharesMap = do
    hMapSize <- Gen.int (Range.constant 0 20)
    stakeholderId <- Gen.list (Range.singleton hMapSize) genStakeholderId
    innerSharesMap <- Gen.list (Range.singleton hMapSize) genInnerSharesMap
    pure $ HM.fromList $ zip stakeholderId innerSharesMap

genSignedCommitment :: ProtocolMagic -> Gen SignedCommitment
genSignedCommitment pm =
    (,,) <$> genPublicKey <*> genCommitment <*> genCommitmentSignature pm

-- We mod the size to the range [0,5000) to give relatively large tests which
-- are still reasonably fast to generate.
-- TODO fix size
genSscPayload :: ProtocolMagic -> Gen SscPayload
genSscPayload pm = Gen.scale (`mod` 5) $
    Gen.choice
        [ CertificatesPayload <$> genVssCertificatesMap pm
        , CommitmentsPayload <$> genCommitmentsMap pm <*> genVssCertificatesMap pm
        , OpeningsPayload <$> genOpeningsMap <*> genVssCertificatesMap pm
        , SharesPayload <$> genSharesMap <*> genVssCertificatesMap pm
        ]

genSscProof :: ProtocolMagic -> Gen SscProof
genSscProof pm = mkSscProof <$> genSscPayload pm

genVssCertificate :: ProtocolMagic -> Gen VssCertificate
genVssCertificate pm =
    mkVssCertificate pm
        <$> genSecretKey
        <*> (asBinary <$> genVssPublicKey)
        <*> genEpochIndex

genVssCertificatesHash :: Gen VssCertificatesHash
genVssCertificatesHash =
    hash <$> genCustomHashMap genStakeholderId (genVssCertificate =<< genProtocolMagic)

genVssCertificatesMap :: ProtocolMagic -> Gen VssCertificatesMap
genVssCertificatesMap pm =
    mkVssCertificatesMap <$> Gen.list (Range.linear 0 10) (genVssCertificate pm)

----------------------------------------------------------------------------
-- Pos.Core.Txp Generators
----------------------------------------------------------------------------

genPkWitness :: ProtocolMagic -> Gen TxInWitness
genPkWitness pm = PkWitness <$> genPublicKey <*> genTxSig pm

genRedeemWitness :: ProtocolMagic -> Gen TxInWitness
genRedeemWitness pm =
    RedeemWitness <$> genRedeemPublicKey <*> genRedeemSignature pm genTxSigData

genScriptWitness :: Gen TxInWitness
genScriptWitness = ScriptWitness <$> genScript <*> genScript

genTx :: Gen Tx
genTx = UnsafeTx <$> genTxInList <*> genTxOutList <*> genTxAttributes

genTxAttributes :: Gen TxAttributes
genTxAttributes = pure $ mkAttributes ()

genTxAux :: ProtocolMagic -> Gen TxAux
genTxAux pm = TxAux <$> genTx <*> (genTxWitness pm)

-- TODO abstract out sampleText, define others as `coerce <$>` over it
-- TODO consider removing `coerce`s
genTxHash :: Gen (Hash Tx)
genTxHash = do
  sampleText <- Gen.text (Range.linear 0 10) Gen.alphaNum
  pure (coerce (hash sampleText :: Hash Text))

genTxId :: Gen TxId
genTxId = genBase16Text >>= pure . decodeHash >>= either error pure
    where
        genBase16Text = decodeUtf8 @Text @ByteString <$> genBase16Bs

--genTxId :: Gen TxId
--genTxId = coerce <$> genTxHash

genTxIn :: Gen TxIn
genTxIn = Gen.choice gens
  where
    gens = [ TxInUtxo <$> genTxId <*> genWord32
           , TxInUnknown <$> genWord8 <*> gen32Bytes
           ]

genTxInList :: Gen (NonEmpty TxIn)
genTxInList = Gen.nonEmpty (Range.linear 1 20) genTxIn

genTxOut :: Gen TxOut
genTxOut = TxOut <$> genAddress <*> genCoin

genTxOutAux :: Gen TxOutAux
genTxOutAux = TxOutAux <$> genTxOut

genTxOutList :: Gen (NonEmpty TxOut)
genTxOutList = Gen.nonEmpty (Range.linear 1 100) genTxOut

-- TODO decide range
genTxPayload :: ProtocolMagic -> Gen TxPayload
genTxPayload pm = mkTxPayload <$> (Gen.list (Range.linear 0 10) txAux')
  where
      txAux' = do
          txInW <- genTxWitness pm
          txIns <- genTxInList
          txOuts <- genTxOutList
          let tx = UnsafeTx txIns txOuts (mkAttributes ())
          pure $ TxAux tx txInW
-- TODO ^ should this replace genTxAux?

    -- UnsafeTxPayload
    --     <$> Gen.list (Range.constant 1 10) genTx
    --     <*> Gen.list (Range.constant 1 10) genTxWitness

-- slow
genTxProof :: ProtocolMagic -> Gen TxProof
genTxProof pm =
    TxProof
        <$> genWord32
        <*> genMerkleRoot genTx
        <*> genAbstractHash (Gen.list (Range.linear 1 20) (genTxWitness pm))

genTxSig :: ProtocolMagic -> Gen TxSig
genTxSig pm =
    sign pm <$> genSignTag <*> genSecretKey <*> genTxSigData

genTxSigData :: Gen TxSigData
genTxSigData = TxSigData <$> genTxHash

genTxInWitness :: ProtocolMagic -> Gen TxInWitness
genTxInWitness pm = Gen.choice gens
  where
    gens = [ genPkWitness pm
           , genRedeemWitness pm
           , genScriptWitness
           , genUnknownWitnessType
           ]

-- TODO decide range
genTxWitness :: ProtocolMagic -> Gen TxWitness
genTxWitness pm = V.fromList <$> Gen.list (Range.linear 1 10) (genTxInWitness pm)

genUnknownWitnessType :: Gen TxInWitness
genUnknownWitnessType =
    UnknownWitnessType <$> Gen.word8 (Range.constant 3 maxBound) <*> gen32Bytes

----------------------------------------------------------------------------
-- Pos.Core.Update Generators
----------------------------------------------------------------------------

genApplicationName :: Gen ApplicationName
genApplicationName =
    ApplicationName <$> Gen.text (Range.constant 0 10) Gen.alphaNum

genBlockVersion :: Gen BlockVersion
genBlockVersion =
    BlockVersion
        <$> Gen.word16 Range.constantBounded
        <*> Gen.word16 Range.constantBounded
        <*> Gen.word8 Range.constantBounded

genBlockVersionData :: Gen BlockVersionData
genBlockVersionData =
    BlockVersionData
        <$> genScriptVersion
        <*> genMillisecond
        <*> genByte
        <*> genByte
        <*> genByte
        <*> genByte
        <*> genCoinPortion
        <*> genCoinPortion
        <*> genCoinPortion
        <*> genCoinPortion
        <*> genFlatSlotId
        <*> genSoftforkRule
        <*> genTxFeePolicy
        <*> genEpochIndex


genBlockVersionModifier :: Gen BlockVersionModifier
genBlockVersionModifier =
    BlockVersionModifier
        <$> Gen.maybe genScriptVersion
        <*> Gen.maybe genMillisecond
        <*> Gen.maybe genByte
        <*> Gen.maybe genByte
        <*> Gen.maybe genByte
        <*> Gen.maybe genByte
        <*> Gen.maybe genCoinPortion
        <*> Gen.maybe genCoinPortion
        <*> Gen.maybe genCoinPortion
        <*> Gen.maybe genCoinPortion
        <*> Gen.maybe genFlatSlotId
        <*> Gen.maybe genSoftforkRule
        <*> Gen.maybe genTxFeePolicy
        <*> Gen.maybe genEpochIndex

genHashRaw :: Gen (Hash Raw)
genHashRaw = genAbstractHash $ Raw <$> gen32Bytes

genSoftforkRule :: Gen SoftforkRule
genSoftforkRule =
    SoftforkRule <$> genCoinPortion <*> genCoinPortion <*> genCoinPortion

genSoftwareVersion :: Gen SoftwareVersion
genSoftwareVersion =
    SoftwareVersion
        <$> genApplicationName
        <*> Gen.word32 Range.constantBounded

genSystemTag :: Gen SystemTag
genSystemTag = SystemTag <$> Gen.text (Range.constant 0 10) Gen.alphaNum

genUpAttributes :: Gen UpAttributes
genUpAttributes = pure $ mkAttributes ()

genUpdateData :: Gen UpdateData
genUpdateData =
    UpdateData
        <$> genHashRaw
        <*> genHashRaw
        <*> genHashRaw
        <*> genHashRaw

genUpdatePayload :: ProtocolMagic -> Gen UpdatePayload
genUpdatePayload pm =
    UpdatePayload
        <$> Gen.maybe (genUpdateProposal pm)
        <*> Gen.list (Range.linear 0 10) (genUpdateVote pm)

genUpdateProof :: ProtocolMagic -> Gen UpdateProof
genUpdateProof pm = genAbstractHash (genUpdatePayload pm)

genUpdateProposal :: ProtocolMagic -> Gen UpdateProposal
genUpdateProposal pm = do
    -- let upAttributes = mkAttributes ()
    -- TODO assess if this needs to copy Pos.Abitrary.Update.Core.genUpdateProposal
    UnsafeUpdateProposal
        <$> genBlockVersion
        <*> genBlockVersionModifier
        <*> genSoftwareVersion
        <*> genUpsData
        <*> genUpAttributes
        <*> genPublicKey
        <*> genSignature pm genUpdateProposalToSign

genUpdateProposals :: Gen UpdateProposals
genUpdateProposals = genCustomHashMap genUpId (genUpdateProposal =<< genProtocolMagic)

genUpdateProposalToSign :: Gen UpdateProposalToSign
genUpdateProposalToSign =
    UpdateProposalToSign
        <$> genBlockVersion
        <*> genBlockVersionModifier
        <*> genSoftwareVersion
        <*> genUpsData
        <*> genUpAttributes

genUpId :: Gen UpId
genUpId = genAbstractHash (genUpdateProposal =<< genProtocolMagic)

genUpsData :: Gen (HM.HashMap SystemTag UpdateData)
genUpsData = do
    hMapSize <- Gen.int (Range.constant 0 20)
    sysTagList <- Gen.list (Range.singleton hMapSize) genSystemTag
    upDataList <- Gen.list (Range.singleton hMapSize) genUpdateData
    pure $ HM.fromList $ zip sysTagList upDataList

genUpdateVote :: ProtocolMagic -> Gen UpdateVote
genUpdateVote pm = mkUpdateVote pm <$> genSecretKey <*> genUpId <*> Gen.bool
        -- <$> genSecretKey
        -- <*> genUpId
        -- <*> Gen.bool
        -- <*> genSignature ((,) <$> genUpId <*> Gen.bool)
-- genUpdateVote pm = mkUpdateVote pm <$> arbitrary <*> arbitrary <*> arbitrary

genVoteId :: Gen VoteId
genVoteId = (,,) <$> genUpId <*> genPublicKey <*> Gen.bool

----------------------------------------------------------------------------
-- Pos.Data.Attributes Generators
----------------------------------------------------------------------------

genAttributes :: Gen a -> Gen (Attributes a)
genAttributes genA =  mkAttributes <$> genA

----------------------------------------------------------------------------
-- Pos.Merkle Generators
----------------------------------------------------------------------------

-- slow
genMerkleTree :: Bi a => Gen a -> Gen (MerkleTree a)
genMerkleTree genA = mkMerkleTree <$> Gen.list (Range.linear 0 10) genA

-- slow
genMerkleRoot :: Bi a => Gen a -> Gen (MerkleRoot a)
genMerkleRoot genA = mtRoot <$> genMerkleTree genA

----------------------------------------------------------------------------
-- Helper Generators
----------------------------------------------------------------------------

customHashMapGen
    :: (Hashable k, Eq k)
    => Gen k -> Gen v -> Gen (HM.HashMap k v)
customHashMapGen keyGen valGen =
    HM.fromList
        <$> (Gen.list (Range.linear 1 10) $ (,) <$> keyGen <*> valGen)

genBase16Bs :: Gen ByteString
genBase16Bs = B16.encode <$> genBytes 32

genBytes :: Int -> Gen ByteString
genBytes n = Gen.bytes (Range.singleton n)

genByte :: Gen Byte
genByte = Gen.integral (Range.constant 0 10)

gen32Bytes :: Gen ByteString
gen32Bytes = genBytes 32

genCustomHashMap
    :: (Hashable k, Eq k)
    => Gen k -> Gen v -> Gen (HM.HashMap k v)
genCustomHashMap genK genV = HM.fromList <$> Gen.list range gen
  where
    gen = (,) <$> genK <*> genV
    range = Range.linear 0 10

genMillisecond :: Gen Millisecond
genMillisecond = fromMicroseconds <$> Gen.integral (Range.constant 0 1000000)

genMicrosecond :: Gen Microsecond
genMicrosecond = fromMicroseconds <$> Gen.integral (Range.constant 0 1000000)

genWord32 :: Gen Word32
genWord32 = Gen.word32 Range.constantBounded

genWord8 :: Gen Word8
genWord8 = Gen.word8 Range.constantBounded
