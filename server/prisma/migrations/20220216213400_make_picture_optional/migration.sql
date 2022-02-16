-- DropForeignKey
ALTER TABLE "User" DROP CONSTRAINT "User_fileId_fkey";

-- AlterTable
ALTER TABLE "User" ALTER COLUMN "fileId" DROP NOT NULL;

-- AddForeignKey
ALTER TABLE "User" ADD CONSTRAINT "User_fileId_fkey" FOREIGN KEY ("fileId") REFERENCES "File"("id") ON DELETE SET NULL ON UPDATE CASCADE;
