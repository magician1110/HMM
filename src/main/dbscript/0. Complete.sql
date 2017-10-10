
DROP TABLE MEMBER CASCADE CONSTRAINTS;
DROP TABLE ITEM CASCADE CONSTRAINTS;
DROP TABLE PURCHASEDITEM CASCADE CONSTRAINTS;
DROP TABLE BOARDCODE CASCADE CONSTRAINTS;
DROP TABLE BOARD CASCADE CONSTRAINTS;
DROP TABLE BOARDPOINT CASCADE CONSTRAINTS;
DROP TABLE ATTACHFILE CASCADE CONSTRAINTS;
DROP TABLE COMMENTS CASCADE CONSTRAINTS;
DROP TABLE COMMENTSPOINT CASCADE CONSTRAINTS;
DROP TABLE REPORTLIST CASCADE CONSTRAINTS;
DROP TABLE CREPORTLIST CASCADE CONSTRAINTS;
DROP TABLE ITEMMOOD CASCADE CONSTRAINTS;
DROP TABLE WEEKSUBJECT CASCADE CONSTRAINTS;
DROP TABLE PROLIST CASCADE CONSTRAINTS;
DROP TABLE CONLIST CASCADE CONSTRAINTS;
DROP TABLE LEVELING;


--멤버
CREATE TABLE MEMBER
(
    MEMBERCODE NUMBER PRIMARY KEY,
    ID VARCHAR2(20) UNIQUE NOT NULL,
    PASSWORD VARCHAR2(200) NOT NULL,
    EMAIL VARCHAR2(30) UNIQUE NOT NULL,
    PHOTO VARCHAR2(200),
    MEDAL NUMBER NOT NULL,
    HAVMEDAL NUMBER NOT NULL,
    EXP NUMBER NOT NULL,
    CASH NUMBER NOT NULL,
    DDARU NUMBER NOT NULL,
    REPORT NUMBER NOT NULL,
    RECOMPOINT NUMBER NOT NULL,
    JOB VARCHAR2(24),
    ENROLLDATE DATE DEFAULT SYSDATE NOT NULL,
    QUITDATE DATE
);

CREATE TABLE LEVELING
(
    LEV NUMBER PRIMARY KEY,
    EXP NUMBER NOT NULL
);
INSERT INTO LEVELING VALUES(LEV_SEQ.NEXTVAL,1);
COMMIT;

DECLARE
    LP NUMBER:=1;
    MULTI NUMBER:=2;
BEGIN
    LOOP       
        IF LP>=75 THEN MULTI:=1.1;
        ELSIF LP>=50 THEN MULTI:=1.2;
        ELSIF LP>=25 THEN MULTI:=1.5;
        END IF;
        
        INSERT INTO LEVELING VALUES(LEV_SEQ.NEXTVAL,FLOOR((SELECT MAX(EXP) FROM LEVELING)*MULTI));
        LP:=LP+1;
        
        EXIT WHEN LP>=100;
    END LOOP;       
END;
/
--아이템
CREATE TABLE ITEMMOOD
(
    MOOD NUMBER NOT NULL PRIMARY KEY,
    NAME VARCHAR(30) NOT NULL
);

CREATE TABLE ITEM
(
    ITEMCODE NUMBER PRIMARY KEY,
    NAME VARCHAR2(30) NOT NULL,
    USAGEDATE NUMBER NOT NULL,
    MOOD NUMBER NOT NULL,
    FILELINK VARCHAR2(100) NOT NULL,
    PRICE NUMBER NOT NULL,
    CONSTRAINT ITEM_MOOD FOREIGN KEY (MOOD) REFERENCES ITEMMOOD (MOOD)
);

CREATE TABLE PURCHASEDITEM
(
    MEMBERCODE NUMBER,
    ITEMCODE NUMBER,
    PURCHASEDATE DATE NOT NULL,
    CONSTRAINT PK_MEMBER_ITEM PRIMARY KEY(MEMBERCODE,ITEMCODE),
    CONSTRAINT FK_MEMBER FOREIGN KEY (MEMBERCODE) REFERENCES MEMBER (MEMBERCODE),
    CONSTRAINT FK_ITEM FOREIGN KEY (ITEMCODE) REFERENCES ITEM (ITEMCODE)
);

--게시글
CREATE TABLE BOARDCODE
(
    DISCODE NUMBER PRIMARY KEY,
    NAME VARCHAR2(20)
);

CREATE TABLE BOARD
(
    BCODE NUMBER PRIMARY KEY,
    TITLE VARCHAR2(120) NOT NULL,
    CONTENT  VARCHAR2(4000),
    DISTINGUISH  NUMBER NOT NULL,
    WRITERID  VARCHAR2(20) NOT NULL,
    POSTDATE DATE DEFAULT SYSDATE NOT NULL ,
    ISDELETE CHAR(1),
    HASFILE CHAR(1),
    CONSTRAINT FK_ID_BOARD FOREIGN KEY (WRITERID) REFERENCES MEMBER (ID),
    CONSTRAINT FK_DISTINGUISH FOREIGN KEY (DISTINGUISH) REFERENCES BOARDCODE (DISCODE)
);

CREATE TABLE BOARDPOINT
(
    BCODE NUMBER PRIMARY KEY,
    VIEWNUM NUMBER DEFAULT 0 NOT NULL,
    BEST NUMBER DEFAULT 0 NOT NULL,
    GOOD NUMBER DEFAULT 0 NOT NULL,
    BAD NUMBER DEFAULT 0 NOT NULL,
    WORST NUMBER DEFAULT 0 NOT NULL,
    CAL NUMBER DEFAULT 0 NOT NULL,
    MEDAL NUMBER DEFAULT 0 NOT NULL,
    REPORT NUMBER DEFAULT 0 NOT NULL,
    CONSTRAINT FK_BOARDPOINT FOREIGN KEY (BCODE) REFERENCES BOARD (BCODE)
);
--첨부파일
CREATE TABLE ATTACHFILE
(
    ATCODE NUMBER PRIMARY KEY,
    ORIGINNAME VARCHAR2(1000) NOT NULL,
    CHANGEDNAME  VARCHAR2(1000) NOT NULL,
    BCODE NUMBER,
    FILELINK  VARCHAR2(2000) NOT NULL,
    CONSTRAINT FK_ATTA_BOARD FOREIGN KEY (BCODE) REFERENCES BOARD (BCODE)    
);
--댓글
CREATE TABLE COMMENTS
(
    CCODE NUMBER PRIMARY KEY,
    CONTENT VARCHAR2(600),
    WRITERID VARCHAR2(20) NOT NULL,
    POSTDATE DATE DEFAULT SYSDATE NOT NULL,
    LEV NUMBER NOT NULL,
    UPPER NUMBER,
    BCODE NUMBER NOT NULL,
    ISDELETE CHAR(1),
    CONSTRAINT FK_COMMENT_BOARD FOREIGN KEY (BCODE) REFERENCES BOARD (BCODE),
    CONSTRAINT FK_COMMENT FOREIGN KEY (UPPER) REFERENCES COMMENTS (CCODE),
    CONSTRAINT FK_COMMENT_ID FOREIGN KEY (WRITERID) REFERENCES MEMBER (ID)  
);

CREATE TABLE COMMENTSPOINT
(
    CCODE NUMBER PRIMARY KEY,
    GOOD NUMBER DEFAULT 0 NOT NULL,
    BAD NUMBER DEFAULT 0 NOT NULL,
    CAL NUMBER DEFAULT 0 NOT NULL,
    MEDAL NUMBER DEFAULT 0 NOT NULL,
    REPORT NUMBER DEFAULT 0 NOT NULL,
    CONSTRAINT FK_COMMENTSPOINT FOREIGN KEY (CCODE) REFERENCES COMMENTS (CCODE)
);
--신고 리스트
CREATE TABLE REPORTLIST
(
    BCODE NUMBER NOT NULL,
    ID VARCHAR2(20) NOT NULL,
    CONSTRAINT REP_BCODE FOREIGN KEY (BCODE) REFERENCES BOARD (BCODE),
    CONSTRAINT REP_ID FOREIGN KEY (ID) REFERENCES MEMBER (ID),
    CONSTRAINT REP_PK PRIMARY KEY (BCODE,ID)
);

CREATE TABLE CREPORTLIST
(
    CCODE NUMBER NOT NULL,
    ID VARCHAR2(20) NOT NULL,
    CONSTRAINT CREP_CCODE FOREIGN KEY (CCODE) REFERENCES COMMENTS (CCODE),
    CONSTRAINT CREP_ID FOREIGN KEY (ID) REFERENCES MEMBER (ID),
    CONSTRAINT CREP_PK PRIMARY KEY (CCODE,ID)
);

DROP SEQUENCE MEM_SEQ;
DROP SEQUENCE ITEM_SEQ;
DROP SEQUENCE BOARD_SEQ;
DROP SEQUENCE ATTACHFILE_SEQ;
DROP SEQUENCE COMMENTS_SEQ;
DROP SEQUENCE NEWTECH_SEQ;
DROP SEQUENCE LEV_SEQ;


CREATE SEQUENCE MEM_SEQ
START WITH 1
INCREMENT BY 1
NOMAXVALUE;

CREATE SEQUENCE ITEM_SEQ
START WITH 1
INCREMENT BY 1
NOMAXVALUE;

CREATE SEQUENCE BOARD_SEQ
START WITH 1
INCREMENT BY 1
NOMAXVALUE;

CREATE SEQUENCE ATTACHFILE_SEQ
START WITH 1
INCREMENT BY 1
NOMAXVALUE;

CREATE SEQUENCE COMMENTS_SEQ
START WITH 1
INCREMENT BY 1
NOMAXVALUE;

CREATE SEQUENCE NEWTECH_SEQ
START WITH 1
INCREMENT BY 1
NOMAXVALUE;

CREATE SEQUENCE LEV_SEQ
START WITH 1
INCREMENT BY 1
NOMAXVALUE;

CREATE OR REPLACE TRIGGER BOARD_TRI
AFTER INSERT ON BOARD
FOR EACH ROW
BEGIN	
    INSERT INTO BOARDPOINT
    VALUES(:NEW.BCODE,0,0,0,0,0,0,0,0);
END; 
/

CREATE OR REPLACE TRIGGER COMMENT_TRI
AFTER INSERT ON COMMENTS
FOR EACH ROW
BEGIN	
    INSERT INTO COMMENTSPOINT
    VALUES(:NEW.CCODE,0,0,0,0,0);
END; 
/

CREATE OR REPLACE TRIGGER BMEDAL_TRI
AFTER UPDATE ON BOARDPOINT
FOR EACH ROW
BEGIN	    
    IF(:NEW.MEDAL!=:OLD.MEDAL)
    THEN 
        UPDATE MEMBER
        SET MEDAL=MEDAL+1
        WHERE ID=(SELECT WRITERID FROM BOARD WHERE BCODE=:NEW.BCODE);
    END IF;
END; 
/

CREATE OR REPLACE TRIGGER CMEDAL_TRI
AFTER UPDATE ON COMMENTSPOINT
FOR EACH ROW
BEGIN	    
    IF(:NEW.MEDAL!=:OLD.MEDAL)
    THEN 
        UPDATE MEMBER
        SET MEDAL=MEDAL+1
        WHERE ID=(SELECT WRITERID FROM COMMENTS WHERE CCODE=:NEW.CCODE);
    END IF;
END; 
/
--게시글 신고 트리거
CREATE OR REPLACE TRIGGER BREPORT_TRI
AFTER INSERT ON REPORTLIST
FOR EACH ROW
BEGIN	    
    UPDATE MEMBER
    SET REPORT=REPORT+1
    WHERE ID=(SELECT WRITERID FROM BOARD WHERE BCODE=:NEW.BCODE);
    
    UPDATE BOARDPOINT
    SET REPORT=REPORT+1
    WHERE BCODE=:NEW.BCODE;
END; 
/

--댓글 신고 트리거
CREATE OR REPLACE TRIGGER CREPORT_TRI
AFTER INSERT ON CREPORTLIST
FOR EACH ROW
BEGIN	    
    UPDATE MEMBER
    SET REPORT=REPORT+1
    WHERE ID=(SELECT WRITERID FROM BOARD WHERE BCODE=(SELECT BCODE FROM COMMENTS WHERE CCODE=:NEW.CCODE));
    
    UPDATE COMMENTSPOINT
    SET REPORT=REPORT+1
    WHERE CCODE=:NEW.CCODE;
END; 
/
--게시글 공감 트리거
CREATE OR REPLACE TRIGGER BRECOM_TRI
AFTER UPDATE ON BOARDPOINT
FOR EACH ROW
BEGIN	  
    IF(:NEW.BEST!=:OLD.BEST)
    THEN 
        UPDATE MEMBER
        SET EXP=EXP+5
        WHERE ID=(SELECT WRITERID FROM BOARD WHERE BCODE=:NEW.BCODE);
    END IF;
    
    IF(:NEW.GOOD!=:OLD.GOOD)
    THEN 
        UPDATE MEMBER
        SET EXP=EXP+3
        WHERE ID=(SELECT WRITERID FROM BOARD WHERE BCODE=:NEW.BCODE);
    END IF;      
END; 
/

--댓글 공감 트리거
CREATE OR REPLACE TRIGGER CRECOM_TRI
AFTER UPDATE ON COMMENTSPOINT
FOR EACH ROW
BEGIN	  
    IF(:NEW.GOOD!=:OLD.GOOD)
    THEN 
        UPDATE MEMBER
        SET EXP=EXP+3
        WHERE ID=(SELECT WRITERID FROM COMMENTS WHERE CCODE=:NEW.CCODE);
    END IF;  
END; 
/

--유저
INSERT INTO MEMBER VALUES(MEM_SEQ.NEXTVAL,'admin','admin','eamil',null,999,999,0,0,0,0,999,null,sysdate,null);
INSERT INTO MEMBER VALUES(MEM_SEQ.NEXTVAL,'user','user','email',null,100,100,0,0,0,0,100,null,sysdate,null);
INSERT INTO MEMBER VALUES(MEM_SEQ.NEXTVAL,'user1','user1','first@hotmail.com',null,500,500,0,0,0,0,0,null,sysdate,null);
INSERT INTO MEMBER VALUES(MEM_SEQ.NEXTVAL,'user2','user2','second@naver.com',null,500,500,0,0,0,0,0,null,sysdate,null);
INSERT INTO MEMBER VALUES(MEM_SEQ.NEXTVAL,'user3','user3','third@hanmail.net',null,500,500,0,0,0,0,0,null,sysdate,null);
INSERT INTO MEMBER VALUES(MEM_SEQ.NEXTVAL,'user4','user4','fourth@google.com',null,0,0,0,0,0,0,0,null,sysdate,null);
INSERT INTO MEMBER VALUES(MEM_SEQ.NEXTVAL,'user5','user5','fifth@yahoo.com',null,0,0,0,0,0,0,0,null,sysdate,null);
INSERT INTO MEMBER VALUES(MEM_SEQ.NEXTVAL,'user6','user6','sixth@hotmail.com',null,0,0,0,0,0,0,0,null,sysdate,null);
INSERT INTO MEMBER VALUES(MEM_SEQ.NEXTVAL,'user7','user7','seventh@hotmail.com',null,0,0,0,0,0,0,0,null,sysdate,null);
INSERT INTO MEMBER VALUES(MEM_SEQ.NEXTVAL,'user8','user8','eighth@daum.net',null,0,0,0,0,0,0,0,null,sysdate,null);
INSERT INTO MEMBER VALUES(MEM_SEQ.NEXTVAL,'user9','user9','ninth@google.com',null,0,0,0,0,0,0,0,null,sysdate,null);
INSERT INTO MEMBER VALUES(MEM_SEQ.NEXTVAL,'user10','user10','tenth@kh.org',null,0,0,0,0,0,0,0,null,sysdate,null);
INSERT INTO MEMBER VALUES(MEM_SEQ.NEXTVAL,'user11','user11','eleventh@omg.com',null,0,0,0,0,0,0,0,null,sysdate,null);
INSERT INTO MEMBER VALUES(MEM_SEQ.NEXTVAL,'user12','user12','tweltwel@reddit.com',null,0,0,0,0,0,0,0,null,sysdate,null);
INSERT INTO MEMBER VALUES(MEM_SEQ.NEXTVAL,'user13','user13','thethirteen@abc.edu',null,0,0,0,0,0,0,0,null,sysdate,null);
INSERT INTO MEMBER VALUES(MEM_SEQ.NEXTVAL,'user14','user14','fourfourten@hacker.com',null,0,0,0,0,0,0,0,null,sysdate,null);
INSERT INTO MEMBER VALUES(MEM_SEQ.NEXTVAL,'user15','user15','onefive@ybn.net',null,0,0,0,0,0,0,0,null,sysdate,null);
INSERT INTO MEMBER VALUES(MEM_SEQ.NEXTVAL,'user16','user16','thexis@pro.net',null,0,0,0,0,0,0,0,null,sysdate,null);
INSERT INTO MEMBER VALUES(MEM_SEQ.NEXTVAL,'user17','user17','sevenone@daum.net',null,0,0,0,0,0,0,0,null,sysdate,null);
INSERT INTO MEMBER VALUES(MEM_SEQ.NEXTVAL,'user18','user18','yeeyee@reddot.org',null,0,0,0,0,0,0,0,null,sysdate,null);
INSERT INTO MEMBER VALUES(MEM_SEQ.NEXTVAL,'user19','user19','hehehe@lol.com',null,0,0,0,0,0,0,0,null,sysdate,null);
INSERT INTO MEMBER VALUES(MEM_SEQ.NEXTVAL,'user20','user20','treenut@treehouse.org',null,0,0,0,0,0,0,0,null,sysdate,null);
INSERT INTO MEMBER VALUES(MEM_SEQ.NEXTVAL,'user21','user21','qnqwbe@treehouse.org',null,0,0,0,0,0,0,0,null,sysdate,null);
INSERT INTO MEMBER VALUES(MEM_SEQ.NEXTVAL,'user22','user22','123xcq2@treehouse.org',null,0,0,0,0,0,0,0,null,sysdate,null);
INSERT INTO MEMBER VALUES(MEM_SEQ.NEXTVAL,'user23','user23','y324s@treehouse.org',null,0,0,0,0,0,0,0,null,sysdate,null);
INSERT INTO MEMBER VALUES(MEM_SEQ.NEXTVAL,'user24','user24','8rfgs@treehouse.org',null,0,0,0,0,0,0,0,null,sysdate,null);
INSERT INTO MEMBER VALUES(MEM_SEQ.NEXTVAL,'user25','user25','234fg@treehouse.org',null,0,0,0,0,0,0,0,null,sysdate,null);

--게시판 코드
INSERT INTO BOARDCODE VALUES (1,'기업');
INSERT INTO BOARDCODE VALUES (2,'QnA');
INSERT INTO BOARDCODE VALUES (3,'신기술');
INSERT INTO BOARDCODE VALUES (4,'아무말대잔치');
INSERT INTO BOARDCODE VALUES (5,'프로젝트/소스');

-- 기업 게시판
INSERT INTO BOARD VALUES(BOARD_SEQ.NEXTVAL,'그린캣소프트(주)에서 함께 서비스를 개발하실 신입/초급 개발자를 모십니다','그린캣소프트(주)에서 함께 서비스를 개발하실 신입/초급 개발자를 모십니다',1,'admin',SYSDATE-2,NULL,NULL);
INSERT INTO BOARD VALUES(BOARD_SEQ.NEXTVAL,'[프리랜서] 단기/ 웹사이트 구축 JAVA 고급 개발자 구인합니다.','[프리랜서] 단기/ 웹사이트 구축 JAVA 고급 개발자 구인합니다.',1,'user1',SYSDATE-2,NULL,NULL);
INSERT INTO BOARD VALUES(BOARD_SEQ.NEXTVAL,'[e커머스 선두업체 정규직] 서비스 개발자를 찾고있습니다.','[e커머스 선두업체 정규직] 서비스 개발자를 찾고있습니다.',1,'user6',SYSDATE-2,NULL,NULL);
INSERT INTO BOARD VALUES(BOARD_SEQ.NEXTVAL,'(주)제이씨엔터테인먼트 Java 웹 프로그래머 모집 공고','(주)제이씨엔터테인먼트 Java 웹 프로그래머 모집 공고',1,'user7',SYSDATE-1,NULL,NULL);
INSERT INTO BOARD VALUES(BOARD_SEQ.NEXTVAL,'(주)사이냅소프트 2007년 신입 및 경력 사원 모집','(주)사이냅소프트 2007년 신입 및 경력 사원 모집',1,'user9',SYSDATE,NULL,NULL);
INSERT INTO BOARD VALUES(BOARD_SEQ.NEXTVAL,'[충무로]보육통합정보시스템 기능개선_중급1명,PL1명','[충무로]보육통합정보시스템 기능개선_중급1명,PL1명',1,'user10',SYSDATE,NULL,NULL);
INSERT INTO BOARD VALUES(BOARD_SEQ.NEXTVAL,'대기업 MES 개발_중~고급_7개월_C#.NET','대기업 MES 개발_중~고급_7개월_C#.NET',1,'admin',SYSDATE,NULL,NULL);
INSERT INTO BOARD VALUES(BOARD_SEQ.NEXTVAL,'대기업) 네비게이션 시스템 SM운영_Java 개발자 (의왕/중급)','대기업) 네비게이션 시스템 SM운영_Java 개발자 (의왕/중급)',1,'user9',SYSDATE,NULL,NULL);
INSERT INTO BOARD VALUES(BOARD_SEQ.NEXTVAL,'보험사_관리업무 구축_Java, Web개발자(JavaScript) [ 광화문 / 중,고급 ]','보험사_관리업무 구축_Java, Web개발자(JavaScript) [ 광화문 / 중,고급 ]',1,'user9',SYSDATE,NULL,NULL);

-- Q&A 게시판
INSERT INTO BOARD VALUES(BOARD_SEQ.NEXTVAL,'MySQL 한글 질문입니다.','MySQL 한글 질문입니다.',2,'user9',SYSDATE-2,NULL,NULL);
INSERT INTO BOARD VALUES(BOARD_SEQ.NEXTVAL,'개발 편의를 위해서 VO 및 DAO 안쓰면 어떤가요?','개발 편의를 위해서 VO 및 DAO 안쓰면 어떤가요?',2,'user1',SYSDATE-2,NULL,NULL);
INSERT INTO BOARD VALUES(BOARD_SEQ.NEXTVAL,'JSP 공부 중 WEB-INF 폴더안에 jsp 파일 관련해서 질문드립니다','JSP 공부 중 WEB-INF 폴더안에 jsp 파일 관련해서 질문드립니다',2,'user7',SYSDATE-1,NULL,NULL);
INSERT INTO BOARD VALUES(BOARD_SEQ.NEXTVAL,'이 방식이 무리가 많이 가는 코딩방식일까요?','이 방식이 무리가 많이 가는 코딩방식일까요?',2,'user3',SYSDATE-1,NULL,NULL);
INSERT INTO BOARD VALUES(BOARD_SEQ.NEXTVAL,'자바스크립트 스코프 질문드립니다.','자바스크립트 스코프 질문드립니다.',2,'admin',SYSDATE-1,NULL,NULL);
INSERT INTO BOARD VALUES(BOARD_SEQ.NEXTVAL,'스프링 프로젝트 war로 만들어서 톰캣에 올리는데 오류가 납니다.','스프링 프로젝트 war로 만들어서 톰캣에 올리는데 오류가 납니다.',2,'user5',SYSDATE-1,NULL,NULL);
INSERT INTO BOARD VALUES(BOARD_SEQ.NEXTVAL,'[질문수정]MySQL 날짜 비교하여 가장 최근값 가져오기','[질문수정]MySQL 날짜 비교하여 가장 최근값 가져오기',2,'user10',SYSDATE-1,NULL,NULL);
INSERT INTO BOARD VALUES(BOARD_SEQ.NEXTVAL,'jsp 한글파일명 다운로드 질문입니다.','jsp 한글파일명 다운로드 질문입니다.',2,'user2',SYSDATE,NULL,NULL);
INSERT INTO BOARD VALUES(BOARD_SEQ.NEXTVAL,'ajax json에러 해결방법 도와주세요! (errorThrown: SyntaxError: Unexpected end of JSON input)','ajax json에러 해결방법 도와주세요! (errorThrown: SyntaxError: Unexpected end of JSON input)',2,'user4',SYSDATE,NULL,NULL);
INSERT INTO BOARD VALUES(BOARD_SEQ.NEXTVAL,'ORA-01722: invalid number 에러 이해가 잘안됩니다.','ORA-01722: invalid number 에러 이해가 잘안됩니다.',2,'user7',SYSDATE,NULL,NULL);

-- 신기술 게시판
INSERT INTO BOARD VALUES(BOARD_SEQ.NEXTVAL,'"개발자 없어서 못 뽑는다" 10대 프로그래밍 기술 - CIO Korea','"개발자 없어서 못 뽑는다" 10대 프로그래밍 기술 - CIO Korea',3,'user8',SYSDATE-2,NULL,NULL);
INSERT INTO BOARD VALUES(BOARD_SEQ.NEXTVAL,'IT 경력 개발을 위한 8가지 트렌드 파악법 - CIO Korea','IT 경력 개발을 위한 8가지 트렌드 파악법 - CIO Korea',3,'user10',SYSDATE-2,NULL,NULL);
INSERT INTO BOARD VALUES(BOARD_SEQ.NEXTVAL,'"두둑한 연봉을 위한" 2017년에 배울 만한 10가지 프로그래밍 언어','"두둑한 연봉을 위한" 2017년에 배울 만한 10가지 프로그래밍 언어',3,'user3',SYSDATE-2,NULL,NULL);
INSERT INTO BOARD VALUES(BOARD_SEQ.NEXTVAL,'"개발자 없어서 못 뽑는다" 10대 프로그래밍 기술','"개발자 없어서 못 뽑는다" 10대 프로그래밍 기술',3,'user8',SYSDATE-2,NULL,NULL);
INSERT INTO BOARD VALUES(BOARD_SEQ.NEXTVAL,'프로그래밍까지 진출한 AI··· "개발자는 데이터 과학자 돼야"','프로그래밍까지 진출한 AI··· "개발자는 데이터 과학자 돼야"',3,'user3',SYSDATE-2,NULL,NULL);
INSERT INTO BOARD VALUES(BOARD_SEQ.NEXTVAL,'AWS-애저-구글, 기업용 클라우드 플랫폼 최강자는 누가 될까?','AWS-애저-구글, 기업용 클라우드 플랫폼 최강자는 누가 될까?',3,'user1',SYSDATE-1,NULL,NULL);
INSERT INTO BOARD VALUES(BOARD_SEQ.NEXTVAL,'이매지네이션, 머신러닝 가속 기능 내장한 칩 디자인 소개','이매지네이션, 머신러닝 가속 기능 내장한 칩 디자인 소개',3,'user7',SYSDATE-1,NULL,NULL);
INSERT INTO BOARD VALUES(BOARD_SEQ.NEXTVAL,'데이터베이스를 재정의하는 신기술 8가지','데이터베이스를 재정의하는 신기술 8가지',3,'user3',SYSDATE,NULL,NULL);
INSERT INTO BOARD VALUES(BOARD_SEQ.NEXTVAL,'프로그래밍까지 진출한 AI··· "개발자는 데이터 과학자 돼야"','프로그래밍까지 진출한 AI··· "개발자는 데이터 과학자 돼야"',3,'admin',SYSDATE,NULL,NULL);
INSERT INTO BOARD VALUES(BOARD_SEQ.NEXTVAL,'어도비 CIO가 IT 조직의 정체성을 재정의한 방법','어도비 CIO가 IT 조직의 정체성을 재정의한 방법',3,'user1',SYSDATE,NULL,NULL);

--신기술 주제
CREATE TABLE WEEKSUBJECT
(
    WSCODE NUMBER PRIMARY KEY,
    TITLE VARCHAR2(100),
    AGREE VARCHAR2(100),
    DISAGREE VARCHAR2(100),
    STARTDATE DATE NOT NULL    
);

--신기술 찬반 리스트
CREATE TABLE PROLIST
(
    WSCODE NUMBER,
    ID VARCHAR2(11),
    CONSTRAINT PK_PROLIST PRIMARY KEY (WSCODE,ID),
    CONSTRAINT PL_ID FOREIGN KEY (ID) REFERENCES MEMBER(ID)
);

INSERT INTO "HMM"."PROLIST" (WSCODE, ID) VALUES ('4', 'user1');
INSERT INTO "HMM"."PROLIST" (WSCODE, ID) VALUES ('4', 'user2');
INSERT INTO "HMM"."PROLIST" (WSCODE, ID) VALUES ('4', 'user3');
INSERT INTO "HMM"."PROLIST" (WSCODE, ID) VALUES ('4', 'user4');

INSERT INTO "HMM"."PROLIST" (WSCODE, ID) VALUES ('5', 'user1');
INSERT INTO "HMM"."PROLIST" (WSCODE, ID) VALUES ('5', 'user2');
INSERT INTO "HMM"."PROLIST" (WSCODE, ID) VALUES ('5', 'user3');
INSERT INTO "HMM"."PROLIST" (WSCODE, ID) VALUES ('5', 'user4');
INSERT INTO "HMM"."PROLIST" (WSCODE, ID) VALUES ('5', 'user5');
INSERT INTO "HMM"."PROLIST" (WSCODE, ID) VALUES ('5', 'user6');

INSERT INTO "HMM"."PROLIST" (WSCODE, ID) VALUES ('6', 'user1');
INSERT INTO "HMM"."PROLIST" (WSCODE, ID) VALUES ('6', 'user2');
INSERT INTO "HMM"."PROLIST" (WSCODE, ID) VALUES ('6', 'user3');
INSERT INTO "HMM"."PROLIST" (WSCODE, ID) VALUES ('6', 'user4');
INSERT INTO "HMM"."PROLIST" (WSCODE, ID) VALUES ('6', 'user5');
INSERT INTO "HMM"."PROLIST" (WSCODE, ID) VALUES ('6', 'user6');
INSERT INTO "HMM"."PROLIST" (WSCODE, ID) VALUES ('6', 'user7');
INSERT INTO "HMM"."PROLIST" (WSCODE, ID) VALUES ('6', 'user8');

INSERT INTO "HMM"."PROLIST" (WSCODE, ID) VALUES ('7', 'user9');
INSERT INTO "HMM"."PROLIST" (WSCODE, ID) VALUES ('7', 'user10');
INSERT INTO "HMM"."PROLIST" (WSCODE, ID) VALUES ('7', 'user11');
INSERT INTO "HMM"."PROLIST" (WSCODE, ID) VALUES ('7', 'user12');
INSERT INTO "HMM"."PROLIST" (WSCODE, ID) VALUES ('7', 'user13');
INSERT INTO "HMM"."PROLIST" (WSCODE, ID) VALUES ('7', 'user14');
INSERT INTO "HMM"."PROLIST" (WSCODE, ID) VALUES ('7', 'user15');
INSERT INTO "HMM"."PROLIST" (WSCODE, ID) VALUES ('7', 'user16');
INSERT INTO "HMM"."PROLIST" (WSCODE, ID) VALUES ('7', 'user17');
INSERT INTO "HMM"."PROLIST" (WSCODE, ID) VALUES ('7', 'user18');
INSERT INTO "HMM"."PROLIST" (WSCODE, ID) VALUES ('7', 'user19');
INSERT INTO "HMM"."PROLIST" (WSCODE, ID) VALUES ('7', 'user20');
INSERT INTO "HMM"."PROLIST" (WSCODE, ID) VALUES ('7', 'user21');
INSERT INTO "HMM"."PROLIST" (WSCODE, ID) VALUES ('7', 'user22');
INSERT INTO "HMM"."PROLIST" (WSCODE, ID) VALUES ('7', 'user23');

CREATE TABLE CONLIST
(
    WSCODE NUMBER,
    ID VARCHAR2(11),
    CONSTRAINT PK_CONLIST PRIMARY KEY (WSCODE,ID),
    CONSTRAINT CL_ID FOREIGN KEY (ID) REFERENCES MEMBER(ID)
);

INSERT INTO "HMM"."CONLIST" (WSCODE, ID) VALUES ('4', 'user9');
INSERT INTO "HMM"."CONLIST" (WSCODE, ID) VALUES ('4', 'user10');
INSERT INTO "HMM"."CONLIST" (WSCODE, ID) VALUES ('4', 'user11');
INSERT INTO "HMM"."CONLIST" (WSCODE, ID) VALUES ('4', 'user12');
INSERT INTO "HMM"."CONLIST" (WSCODE, ID) VALUES ('4', 'user13');
INSERT INTO "HMM"."CONLIST" (WSCODE, ID) VALUES ('4', 'user14');

INSERT INTO "HMM"."CONLIST" (WSCODE, ID) VALUES ('5', 'user9');
INSERT INTO "HMM"."CONLIST" (WSCODE, ID) VALUES ('5', 'user10');
INSERT INTO "HMM"."CONLIST" (WSCODE, ID) VALUES ('5', 'user11');
INSERT INTO "HMM"."CONLIST" (WSCODE, ID) VALUES ('5', 'user12');
INSERT INTO "HMM"."CONLIST" (WSCODE, ID) VALUES ('5', 'user13');
INSERT INTO "HMM"."CONLIST" (WSCODE, ID) VALUES ('5', 'user14');
INSERT INTO "HMM"."CONLIST" (WSCODE, ID) VALUES ('5', 'user15');
INSERT INTO "HMM"."CONLIST" (WSCODE, ID) VALUES ('5', 'user16');

INSERT INTO "HMM"."CONLIST" (WSCODE, ID) VALUES ('6', 'user9');
INSERT INTO "HMM"."CONLIST" (WSCODE, ID) VALUES ('6', 'user10');
INSERT INTO "HMM"."CONLIST" (WSCODE, ID) VALUES ('6', 'user11');
INSERT INTO "HMM"."CONLIST" (WSCODE, ID) VALUES ('6', 'user12');
INSERT INTO "HMM"."CONLIST" (WSCODE, ID) VALUES ('6', 'user13');
INSERT INTO "HMM"."CONLIST" (WSCODE, ID) VALUES ('6', 'user14');
INSERT INTO "HMM"."CONLIST" (WSCODE, ID) VALUES ('6', 'user15');
INSERT INTO "HMM"."CONLIST" (WSCODE, ID) VALUES ('6', 'user16');
INSERT INTO "HMM"."CONLIST" (WSCODE, ID) VALUES ('6', 'user17');
INSERT INTO "HMM"."CONLIST" (WSCODE, ID) VALUES ('6', 'user18');
INSERT INTO "HMM"."CONLIST" (WSCODE, ID) VALUES ('6', 'user19');
INSERT INTO "HMM"."CONLIST" (WSCODE, ID) VALUES ('6', 'user20');
INSERT INTO "HMM"."CONLIST" (WSCODE, ID) VALUES ('6', 'user21');
INSERT INTO "HMM"."CONLIST" (WSCODE, ID) VALUES ('6', 'user22');
INSERT INTO "HMM"."CONLIST" (WSCODE, ID) VALUES ('6', 'user23');
INSERT INTO "HMM"."CONLIST" (WSCODE, ID) VALUES ('6', 'user24');
INSERT INTO "HMM"."CONLIST" (WSCODE, ID) VALUES ('6', 'user25');

INSERT INTO "HMM"."CONLIST" (WSCODE, ID) VALUES ('7', 'user1');
INSERT INTO "HMM"."CONLIST" (WSCODE, ID) VALUES ('7', 'user2');
INSERT INTO "HMM"."CONLIST" (WSCODE, ID) VALUES ('7', 'user3');
INSERT INTO "HMM"."CONLIST" (WSCODE, ID) VALUES ('7', 'user4');
INSERT INTO "HMM"."CONLIST" (WSCODE, ID) VALUES ('7', 'user5');
INSERT INTO "HMM"."CONLIST" (WSCODE, ID) VALUES ('7', 'user6');
INSERT INTO "HMM"."CONLIST" (WSCODE, ID) VALUES ('7', 'user7');

-- 아무말 대잔치
INSERT INTO BOARD VALUES(BOARD_SEQ.NEXTVAL,'오늘 생일이네요','오늘 생일이네요',4,'admin',SYSDATE-2,NULL,NULL);
INSERT INTO BOARD VALUES(BOARD_SEQ.NEXTVAL,'토익 준비해야되나요?(재취업하고싶어요.)','토익 준비해야되나요?(재취업하고싶어요.)',4,'admin',SYSDATE-2,NULL,NULL);
INSERT INTO BOARD VALUES(BOARD_SEQ.NEXTVAL,'안드로이드 스터디는 어디서 구할 수 있을까요...?','안드로이드 스터디는 어디서 구할 수 있을까요...?',4,'user3',SYSDATE-2,NULL,NULL);
INSERT INTO BOARD VALUES(BOARD_SEQ.NEXTVAL,'채용공고는 수습기간이 지나야 사라지나요?','채용공고는 수습기간이 지나야 사라지나요?',4,'user7',SYSDATE-2,NULL,NULL);
INSERT INTO BOARD VALUES(BOARD_SEQ.NEXTVAL,'26살 개발자를 꿈꾸고 있습니다. 조언부탁드립니다.','26살 개발자를 꿈꾸고 있습니다. 조언부탁드립니다.',4,'user9',SYSDATE-1,NULL,NULL);
INSERT INTO BOARD VALUES(BOARD_SEQ.NEXTVAL,'연봉협상이란게 이런거 였네요','연봉협상이란게 이런거 였네요',4,'user2',SYSDATE-1,NULL,NULL);
INSERT INTO BOARD VALUES(BOARD_SEQ.NEXTVAL,'취준생 입니다. 조언좀 해주세요','취준생 입니다. 조언좀 해주세요',4,'user4',SYSDATE,NULL,NULL);
INSERT INTO BOARD VALUES(BOARD_SEQ.NEXTVAL,'취업성공패키지 학원을 고르고있는데 팁같은게있을까요?','취업성공패키지 학원을 고르고있는데 팁같은게있을까요?',4,'user6',SYSDATE,NULL,NULL);
INSERT INTO BOARD VALUES(BOARD_SEQ.NEXTVAL,'업계 선배님들은 어떻게 처음을 시작하셨나요?','업계 선배님들은 어떻게 처음을 시작하셨나요?',4,'user10',SYSDATE,NULL,NULL);
INSERT INTO BOARD VALUES(BOARD_SEQ.NEXTVAL,'27살에 두번째 학원을 가려합니다','27살에 두번째 학원을 가려합니다',4,'user8',SYSDATE,NULL,NULL);

-- 프로젝트 & 소스
INSERT INTO BOARD VALUES(BOARD_SEQ.NEXTVAL,'node.js의 passport-LocalStrategy에서 alert창을 띄우려고 합니다.','node.js의 passport-LocalStrategy에서 alert창을 띄우려고 합니다.',5,'user2',SYSDATE-2,NULL,NULL);
INSERT INTO BOARD VALUES(BOARD_SEQ.NEXTVAL,'쇼핑몰 LG U+ 모바일 결제 시스템 구축하고있거든요.','쇼핑몰 LG U+ 모바일 결제 시스템 구축하고있거든요.',5,'user7',SYSDATE-2,NULL,NULL);
INSERT INTO BOARD VALUES(BOARD_SEQ.NEXTVAL,'CHECKOUT 받을때마다 라이브러리를 따로 추가해야 해서 귀찮습니다.','CHECKOUT 받을때마다 라이브러리를 따로 추가해야 해서 귀찮습니다.',5,'user9',SYSDATE-2,NULL,NULL);
INSERT INTO BOARD VALUES(BOARD_SEQ.NEXTVAL,'Maven 프로젝트를 Git으로 관리할 때 pom.properties 문제','Maven 프로젝트를 Git으로 관리할 때 pom.properties 문제',5,'user3',SYSDATE-2,NULL,NULL);
INSERT INTO BOARD VALUES(BOARD_SEQ.NEXTVAL,'spring 업로드 이미지 다시 불러오기','spring 업로드 이미지 다시 불러오기',5,'user1',SYSDATE-1,NULL,NULL);
INSERT INTO BOARD VALUES(BOARD_SEQ.NEXTVAL,'mysql/mariaDB group by 하기 전에 정렬 하는 방법','mysql/mariaDB group by 하기 전에 정렬 하는 방법',5,'user6',SYSDATE-1,NULL,NULL);
INSERT INTO BOARD VALUES(BOARD_SEQ.NEXTVAL,'하이브리드앱과 SPA(Single Page Application)','하이브리드앱과 SPA(Single Page Application)',5,'user9',SYSDATE-1,NULL,NULL);
INSERT INTO BOARD VALUES(BOARD_SEQ.NEXTVAL,'[css, jquery, javascript] 큰화면(div) 안에 여러 블럭(div) inline-block','[css, jquery, javascript] 큰화면(div) 안에 여러 블럭(div) inline-block',5,'user9',SYSDATE,NULL,NULL);
INSERT INTO BOARD VALUES(BOARD_SEQ.NEXTVAL,'CHECKOUT 받을때마다 라이브러리를 따로 추가해야 해서 귀찮습니다.','CHECKOUT 받을때마다 라이브러리를 따로 추가해야 해서 귀찮습니다.',5,'user9',SYSDATE,NULL,NULL);

--댓글 대댓글
INSERT INTO COMMENTS VALUES(COMMENTS_SEQ.NEXTVAL,'1','user1',SYSDATE,1,NULL,1,NULL);
INSERT INTO COMMENTS VALUES(COMMENTS_SEQ.NEXTVAL,'2','user3',SYSDATE,1,NULL,2,NULL);
INSERT INTO COMMENTS VALUES(COMMENTS_SEQ.NEXTVAL,'3','user6',SYSDATE,1,NULL,3,NULL);
INSERT INTO COMMENTS VALUES(COMMENTS_SEQ.NEXTVAL,'4','user8',SYSDATE,1,NULL,4,NULL);
INSERT INTO COMMENTS VALUES(COMMENTS_SEQ.NEXTVAL,'5','user10',SYSDATE,1,NULL,5,NULL);

INSERT INTO COMMENTS VALUES(COMMENTS_SEQ.NEXTVAL,'6','admin',SYSDATE,1,NULL,1,NULL);
INSERT INTO COMMENTS VALUES(COMMENTS_SEQ.NEXTVAL,'7','user2',SYSDATE,1,NULL,2,NULL);
INSERT INTO COMMENTS VALUES(COMMENTS_SEQ.NEXTVAL,'8','user10',SYSDATE,1,NULL,3,NULL);
INSERT INTO COMMENTS VALUES(COMMENTS_SEQ.NEXTVAL,'9','user3',SYSDATE,1,NULL,4,NULL);
INSERT INTO COMMENTS VALUES(COMMENTS_SEQ.NEXTVAL,'10','user6',SYSDATE,1,NULL,5,NULL);

INSERT INTO COMMENTS VALUES(COMMENTS_SEQ.NEXTVAL,'11','user3',SYSDATE,1,NULL,1,NULL);
INSERT INTO COMMENTS VALUES(COMMENTS_SEQ.NEXTVAL,'12','user1',SYSDATE,1,NULL,2,NULL);
INSERT INTO COMMENTS VALUES(COMMENTS_SEQ.NEXTVAL,'13','user4',SYSDATE,1,NULL,3,NULL);
INSERT INTO COMMENTS VALUES(COMMENTS_SEQ.NEXTVAL,'14','user9',SYSDATE,1,NULL,4,NULL);
INSERT INTO COMMENTS VALUES(COMMENTS_SEQ.NEXTVAL,'15','user3',SYSDATE,1,NULL,5,NULL);

INSERT INTO COMMENTS VALUES(COMMENTS_SEQ.NEXTVAL,'16','user1',SYSDATE,1,NULL,1,NULL);
INSERT INTO COMMENTS VALUES(COMMENTS_SEQ.NEXTVAL,'17','user9',SYSDATE,1,NULL,2,NULL);
INSERT INTO COMMENTS VALUES(COMMENTS_SEQ.NEXTVAL,'18','user2',SYSDATE,1,NULL,3,NULL);
INSERT INTO COMMENTS VALUES(COMMENTS_SEQ.NEXTVAL,'19','user8',SYSDATE,1,NULL,4,NULL);
INSERT INTO COMMENTS VALUES(COMMENTS_SEQ.NEXTVAL,'20','user6',SYSDATE,1,NULL,5,NULL);

INSERT INTO COMMENTS VALUES(COMMENTS_SEQ.NEXTVAL,'21','user4',SYSDATE,1,NULL,1,NULL);
INSERT INTO COMMENTS VALUES(COMMENTS_SEQ.NEXTVAL,'22','user8',SYSDATE,1,NULL,2,NULL);
INSERT INTO COMMENTS VALUES(COMMENTS_SEQ.NEXTVAL,'23','user2',SYSDATE,1,NULL,3,NULL);
INSERT INTO COMMENTS VALUES(COMMENTS_SEQ.NEXTVAL,'24','user3',SYSDATE,1,NULL,4,NULL);
INSERT INTO COMMENTS VALUES(COMMENTS_SEQ.NEXTVAL,'25','user1',SYSDATE,1,NULL,5,NULL);
INSERT INTO COMMENTS VALUES(COMMENTS_SEQ.NEXTVAL,'26','admin',SYSDATE,2,1,1,NULL);
INSERT INTO COMMENTS VALUES(COMMENTS_SEQ.NEXTVAL,'27','user6',SYSDATE,2,1,1,NULL);
INSERT INTO COMMENTS VALUES(COMMENTS_SEQ.NEXTVAL,'28','user3',SYSDATE,2,1,1,NULL);

INSERT INTO COMMENTS VALUES(COMMENTS_SEQ.NEXTVAL,'31','admin',SYSDATE,2,2,2,NULL);
INSERT INTO COMMENTS VALUES(COMMENTS_SEQ.NEXTVAL,'32','user7',SYSDATE,2,2,2,NULL);
INSERT INTO COMMENTS VALUES(COMMENTS_SEQ.NEXTVAL,'33','user5',SYSDATE,2,2,2,NULL);


INSERT INTO COMMENTS VALUES(COMMENTS_SEQ.NEXTVAL,'36','user1',SYSDATE,2,3,3,NULL);
INSERT INTO COMMENTS VALUES(COMMENTS_SEQ.NEXTVAL,'37','admin',SYSDATE,2,3,3,NULL);
INSERT INTO COMMENTS VALUES(COMMENTS_SEQ.NEXTVAL,'38','user4',SYSDATE,2,3,3,NULL);


INSERT INTO COMMENTS VALUES(COMMENTS_SEQ.NEXTVAL,'41$','user4',SYSDATE,2,4,4,NULL);
INSERT INTO COMMENTS VALUES(COMMENTS_SEQ.NEXTVAL,'42','admin',SYSDATE,2,4,4,NULL);
INSERT INTO COMMENTS VALUES(COMMENTS_SEQ.NEXTVAL,'43','user1',SYSDATE,2,4,4,NULL);


INSERT INTO COMMENTS VALUES(COMMENTS_SEQ.NEXTVAL,'46','user9',SYSDATE,2,5,5,NULL);
INSERT INTO COMMENTS VALUES(COMMENTS_SEQ.NEXTVAL,'47','user4',SYSDATE,2,5,5,NULL);
INSERT INTO COMMENTS VALUES(COMMENTS_SEQ.NEXTVAL,'48','admin',SYSDATE,2,5,5,NULL);



--아이템무드
INSERT INTO ITEMMOOD VALUES(1,'CRAZY');
INSERT INTO ITEMMOOD VALUES(2,'HAPPY');
INSERT INTO ITEMMOOD VALUES(3,'SAD');
INSERT INTO ITEMMOOD VALUES(4,'BAD');
INSERT INTO ITEMMOOD VALUES(5,'MEDAL');
INSERT INTO ITEMMOOD VALUES(6,'BORDER');

--신기술 주제
INSERT INTO WEEKSUBJECT VALUES
(
	NEWTECH_SEQ.NEXTVAL,'반장의 연애는 30대 전까지 가능하다?','언제까지고 미룰 수 없다.','ㅋㅋㅋ',TO_DATE('2017-08-28','YYYY-MM-DD')
);

INSERT INTO WEEKSUBJECT VALUES
(
	NEWTECH_SEQ.NEXTVAL,'스타워즈? 스타트렉?','당연히 스타워즈','물론 스타트렉',TO_DATE('2017-09-04','YYYY-MM-DD')
);

INSERT INTO WEEKSUBJECT VALUES
(
	NEWTECH_SEQ.NEXTVAL,'웹 개발자? 프로그래머? 우리 자신을 어떻게 불러야 할까요?','웹 개발자','프로그래머',TO_DATE('2017-09-11','YYYY-MM-DD')
);

INSERT INTO WEEKSUBJECT VALUES
(
	NEWTECH_SEQ.NEXTVAL,'차세대 웹개발의 주역인 학생분들! 무엇을 공부하고 있습니까?','자바','자바스크립트',TO_DATE('2017-09-18','YYYY-MM-DD')
);

INSERT INTO WEEKSUBJECT VALUES
(
	NEWTECH_SEQ.NEXTVAL,'풀 스택 개발자가 갖춰야할 가장 중요한 기술은?','자바스크립트','SQL',TO_DATE('2017-09-25','YYYY-MM-DD')
);

INSERT INTO WEEKSUBJECT VALUES
(
	NEWTECH_SEQ.NEXTVAL,'2018년 웹개발의 중점은 무엇일까?','심미성과 편의성이 중요한 프론트 엔드!','안정성과 유지보수가 중요한 백 엔드!',TO_DATE('2017-10-02','YYYY-MM-DD')
);

INSERT INTO WEEKSUBJECT VALUES
(
	NEWTECH_SEQ.NEXTVAL,'프론트 엔드의 핵심 기술은 과연 무엇인가?','자바스크립트','앵귤러',TO_DATE('2017-10-09','YYYY-MM-DD')
);

INSERT INTO WEEKSUBJECT VALUES
(
	NEWTECH_SEQ.NEXTVAL,'반장의 연애는 100대 전까지 가능하다?','가십시다.','머나먼 곳으로',TO_DATE('2017-10-16','YYYY-MM-DD')
);
--빈 신기술 공간
DECLARE
    LP NUMBER:=1;
    MDATE DATE;
BEGIN
    LOOP   
        INSERT INTO WEEKSUBJECT VALUES (NEWTECH_SEQ.NEXTVAL,NULL,NULL,NULL,(SELECT MAX(STARTDATE)+7 FROM WEEKSUBJECT));
        LP:=LP+1;        
        EXIT WHEN LP>=92;
    END LOOP;       
END;
/

COMMIT;

insert into item values(ITEM_SEQ.NEXTVAL, 'crazy1',30,1,'resources/img/icon/1.crazy/crazy1.gif',250);
insert into item values(ITEM_SEQ.NEXTVAL, 'crazy2',30,1,'resources/img/icon/1.crazy/crazy2.gif',250);
insert into item values(ITEM_SEQ.NEXTVAL, 'crazy3',30,1,'resources/img/icon/1.crazy/crazy3.gif',250);
insert into item values(ITEM_SEQ.NEXTVAL, 'crazy4',30,1,'resources/img/icon/1.crazy/crazy4.gif',250);
insert into item values(ITEM_SEQ.NEXTVAL, 'crazy5',30,1,'resources/img/icon/1.crazy/crazy5.gif',250);
insert into item values(ITEM_SEQ.NEXTVAL, 'crazy6',30,1,'resources/img/icon/1.crazy/crazy6.gif',250);
insert into item values(ITEM_SEQ.NEXTVAL, 'crazy7',30,1,'resources/img/icon/1.crazy/crazy7.gif',250);
 
insert into item values(ITEM_SEQ.NEXTVAL, 'happy1',30,2,'resources/img/icon/2.happy/happy1.gif',250);
insert into item values(ITEM_SEQ.NEXTVAL, 'happy2',30,2,'resources/img/icon/2.happy/happy2.gif',250);
insert into item values(ITEM_SEQ.NEXTVAL, 'happy3',30,2,'resources/img/icon/2.happy/happy3.gif',250);
insert into item values(ITEM_SEQ.NEXTVAL, 'happy4',30,2,'resources/img/icon/2.happy/happy4.gif',250);
insert into item values(ITEM_SEQ.NEXTVAL, 'happy5',30,2,'resources/img/icon/2.happy/happy5.gif',250);
insert into item values(ITEM_SEQ.NEXTVAL, 'happy6',30,2,'resources/img/icon/2.happy/happy6.gif',250);
insert into item values(ITEM_SEQ.NEXTVAL, 'happy7',30,2,'resources/img/icon/2.happy/happy7.gif',250);
insert into item values(ITEM_SEQ.NEXTVAL, 'happy8',30,2,'resources/img/icon/2.happy/happy8.gif',250);

insert into item values(ITEM_SEQ.NEXTVAL, 'sad1',30,3,'resources/img/icon/3.sad/sad1.gif',250);
insert into item values(ITEM_SEQ.NEXTVAL, 'sad2',30,3,'resources/img/icon/3.sad/sad2.gif',250);
insert into item values(ITEM_SEQ.NEXTVAL, 'sad3',30,3,'resources/img/icon/3.sad/sad3.gif',250);
insert into item values(ITEM_SEQ.NEXTVAL, 'sad4',30,3,'resources/img/icon/3.sad/sad4.gif',250);
insert into item values(ITEM_SEQ.NEXTVAL, 'sad5',30,3,'resources/img/icon/3.sad/sad5.gif',250);
insert into item values(ITEM_SEQ.NEXTVAL, 'sad6',30,3,'resources/img/icon/3.sad/sad6.gif',250);
insert into item values(ITEM_SEQ.NEXTVAL, 'sad7',30,3,'resources/img/icon/3.sad/sad7.gif',250);
insert into item values(ITEM_SEQ.NEXTVAL, 'sad8',30,3,'resources/img/icon/3.sad/sad8.gif',250);
 
insert into item values(ITEM_SEQ.NEXTVAL, 'bad1',30,4,'resources/img/icon/4.bad/bad1.gif',250);
insert into item values(ITEM_SEQ.NEXTVAL, 'bad2',30,4,'resources/img/icon/4.bad/bad2.gif',250);
insert into item values(ITEM_SEQ.NEXTVAL, 'bad3',30,4,'resources/img/icon/4.bad/bad3.gif',250);
insert into item values(ITEM_SEQ.NEXTVAL, 'bad4',30,4,'resources/img/icon/4.bad/bad4.gif',250);
insert into item values(ITEM_SEQ.NEXTVAL, 'bad5',30,4,'resources/img/icon/4.bad/bad5.gif',250);
insert into item values(ITEM_SEQ.NEXTVAL, 'bad6',30,4,'resources/img/icon/4.bad/bad6.gif',250);
insert into item values(ITEM_SEQ.NEXTVAL, 'bad7',30,4,'resources/img/icon/4.bad/bad7.gif',250);
insert into item values(ITEM_SEQ.NEXTVAL, 'bad8',30,4,'resources/img/icon/4.bad/bad8.gif',250);

insert into item values(ITEM_SEQ.NEXTVAL, 'medal1',30,5,'resources/img/icon/5.medal/medal1.gif',250);
insert into item values(ITEM_SEQ.NEXTVAL, 'medal2',30,5,'resources/img/icon/5.medal/medal2.gif',250);
insert into item values(ITEM_SEQ.NEXTVAL, 'medal3',30,5,'resources/img/icon/5.medal/medal3.gif',250);

insert into item values(ITEM_SEQ.NEXTVAL, 'bg1',30,6,'resources/img/icon/6.border/bg1.gif',250);
insert into item values(ITEM_SEQ.NEXTVAL, 'bg2',30,6,'resources/img/icon/6.border/bg2.gif',250);
insert into item values(ITEM_SEQ.NEXTVAL, 'bg3',30,6,'resources/img/icon/6.border/bg3.gif',250);
insert into item values(ITEM_SEQ.NEXTVAL, 'bg4',30,6,'resources/img/icon/6.border/bg4.gif',250);
insert into item values(ITEM_SEQ.NEXTVAL, 'bg5',30,6,'resources/img/icon/6.border/bg5.gif',250);
insert into item values(ITEM_SEQ.NEXTVAL, 'bg6',30,6,'resources/img/icon/6.border/bg6.gif',250);
insert into item values(ITEM_SEQ.NEXTVAL, 'bg7',30,6,'resources/img/icon/6.border/bg7.gif',250);
insert into item values(ITEM_SEQ.NEXTVAL, 'bg8',30,6,'resources/img/icon/6.border/bg8.gif',250);
insert into item values(ITEM_SEQ.NEXTVAL, 'bg9',30,6,'resources/img/icon/6.border/bg9.gif',250);

COMMIT;