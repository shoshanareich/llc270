#include "AUTODIFF_OPTIONS.h"
#ifdef ALLOW_CTRL
# include "CTRL_OPTIONS.h"
#endif

      SUBROUTINE ADAUTODIFF_INADMODE_UNSET( myTime, myIter, myThid )
C     *==========================================================*
C     | SUBROUTINE ADAUTODIFF_INADMODE_UNSET
C     *==========================================================*

C     !USES:
      IMPLICIT NONE
C     == Global variables ===
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "AUTODIFF_PARAMS.h"
#ifdef ALLOW_SEAICE
#include "SEAICE_SIZE.h"
#include "SEAICE_PARAMS.h"
#endif
#ifdef ALLOW_CTRL
# include "CTRL_SIZE.h"
# include "CTRL.h"
#endif
#ifdef ALLOW_AUTODIFF_MONITOR
# ifdef ALLOW_DIAGNOSTICS
#  include "DIAGNOSTICS_SIZE.h"
#  include "DIAGNOSTICS.h"
# endif
#endif /* ALLOW_AUTODIFF_MONITOR */

C     !INPUT/OUTPUT PARAMETERS:
C     myTime    :: Current time in simulation
C     myIter    :: Current iteration number
C     myThid    :: my Thread Id number
      _RL     myTime
      INTEGER myIter
      INTEGER myThid

C     !LOCAL VARIABLES:
      INTEGER k
      CHARACTER*(MAX_LEN_MBUF) msgBuf

#ifdef ALLOW_AUTODIFF_MONITOR
# ifdef ALLOW_DIAGNOSTICS
      LOGICAL modelEnd
C --- Write the fields out here
      IF ( useDiag4AdjOutp ) THEN
C --- Grab modelEnd, necessary input for diagnostics routines
       modelEnd = myTime.EQ.startTime .OR. myIter.EQ.nIter0
       CALL TIMER_START('I/O (WRITE)        [ADJOINT LOOP]', myThid )
       CALL DIAGNOSTICS_WRITE_ADJ( modelEnd, myTime, myIter, myThid )
       CALL TIMER_STOP( 'I/O (WRITE)        [ADJOINT LOOP]', myThid )
      ENDIF
# endif /* ALLOW_DIAGNOSTICS */
#endif /* ALLOW_AUTODIFF_MONITOR */

      inAdMode  = .FALSE.

      useKPP    = useKPPinFwdMode
      useGMRedi = useGMRediInFwdMode
      useSEAICE = useSEAICEinFwdMode
      useGGL90    = useGGL90inFwdMode
      useSALT_PLUME    = useSALT_PLUMEinFwdMode
#ifdef ALLOW_SEAICE
      IF ( SEAICEuseFREEDRIFTswitchInAd ) THEN
        SEAICEuseFREEDRIFT = SEAICEuseFREEDRIFTinFwdMode
        SEAICEuseLSR       = .NOT.SEAICEuseFREEDRIFT
      ENDIF
      IF ( SEAICEuseDYNAMICSswitchInAd ) THEN
        SEAICEuseDYNAMICS  = SEAICEuseDYNAMICSinFwdMode
      ENDIF
      SEAICEadjMODE=0
C     SIregFacInFw = UNSET_RL by default, so we need to check this here
      IF ( SIregFacInFw .NE. UNSET_RL ) SINegFac = SIregFacInFw
#endif /* ALLOW_SEAICE */
      viscFacAdj=viscFacInFw

c      viscFacAdj=0. _d 0
C hzh>>      
      viscAhGrid=1.E-2 !1x "data"
c viscAhGrid default to 0
      diffKhS=1.E1     !
      diffKhT=1.E1     !
cc     viscAr=0.5E-4    !
cc     diffKrS=1.E-5    !
cc     diffKrT=1.E-5    !
      do k=1,Nr
         viscArNr(k)  = 0.5E-4
c         diffKrNrT(k) = 1.E-5
c         diffKrNrS(k) = 1.E-5
      enddo
C hzh<<  

      IF ( debugLevel.GE.debLevC ) THEN
       WRITE(msgBuf,'(A,L5)')
     &      'S/R ADAUTODIFF_INADMODE_UNSET: useKPP    =', useKPP
       CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
       WRITE(msgBuf,'(A,L5)')
     &      'S/R ADAUTODIFF_INADMODE_UNSET: useGMRedi =', useGMRedi
       CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
       WRITE(msgBuf,'(A,L5)')
     &      'S/R ADAUTODIFF_INADMODE_UNSET: useSEAICE =', useSEAICE
       CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
       WRITE(msgBuf,'(A,L5)')
     &      'S/R ADAUTODIFF_INADMODE_UNSET: useGGL90    =', useGGL90
       CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
       WRITE(msgBuf,'(A,L5)')
     &      'S/R ADAUTODIFF_INADMODE_UNSET: useSALT_PLUME    =',
     &      useSALT_PLUME
       CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )

       WRITE(msgBuf,'(A,1PE21.14)')
     &      'S/R ADAUTODIFF_INADMODE_UNSET: viscFacAdj =',viscFacAdj
       CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )

#ifdef ALLOW_SEAICE
       IF ( SEAICEuseFREEDRIFTswitchInAd ) THEN
         WRITE(msgBuf,'(2A,L5)') 'S/R ADAUTODIFF_INADMODE_UNSET: ',
     &        'SEAICEuseFREEDRIFT =', SEAICEuseFREEDRIFT
         CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                       SQUEEZE_RIGHT, myThid )
         WRITE(msgBuf,'(2A,L5)') 'S/R ADAUTODIFF_INADMODE_UNSET: ',
     &        'SEAICEuseLSR       =', SEAICEuseLSR
         CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                       SQUEEZE_RIGHT, myThid )
       ENDIF
       IF ( SEAICEuseDYNAMICSswitchInAd ) THEN
         WRITE(msgBuf,'(2A,L5)') 'S/R ADAUTODIFF_INADMODE_UNSET: ',
     &        'SEAICEuseDYNAMICS =', SEAICEuseDYNAMICS
         CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                       SQUEEZE_RIGHT, myThid )
       ENDIF
       IF ( SEAICEapproxLevInAd.NE.0 ) THEN
         WRITE(msgBuf,'(2A,I2)') 'S/R ADAUTODIFF_INADMODE_UNSET: ',
     &        'SEAICEadjMODE =', SEAICEadjMODE
         CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                       SQUEEZE_RIGHT, myThid )
       ENDIF
#endif /* ALLOW_SEAICE */

      ENDIF

      RETURN
      END
